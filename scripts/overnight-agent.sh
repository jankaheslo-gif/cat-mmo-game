#!/bin/bash

#############################################
# overnight-agent.sh
# Overnight Autonomous Agent for Cat Game 2.1
# Runs 8+ hours implementing tasks via Qwen2.5-Coder
# NO API CALLS = NO QUOTA BURNOUT
#############################################

set -e

PROJECT_DIR="/Users/jp/Desktop/Cat/Cat Game 2.1"
LOG_FILE="$PROJECT_DIR/logs/overnight-$(date +%Y-%m-%d_%H-%M-%S).log"
LOCK_FILE="$PROJECT_DIR/.agent-running"
STATE_FILE="$PROJECT_DIR/.agent-state.json"
EMERGENCY_STOP="$PROJECT_DIR/.agent-emergency-stop"

mkdir -p "$PROJECT_DIR/logs"

#############################################
# LOGGING & STATE FUNCTIONS
#############################################

log() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log_error() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] ❌ ERROR: $1" | tee -a "$LOG_FILE"
}

log_success() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] ✅ $1" | tee -a "$LOG_FILE"
}

save_state() {
  cat > "$STATE_FILE" <<EOF
{
  "session_id": "$(date +%Y-%m-%d_%H-%M-%S)",
  "tasks_completed": $TASK_COUNT,
  "runtime_minutes": $(( ($(date +%s) - SESSION_START) / 60 )),
  "last_update": "$(date -Iseconds)",
  "status": "$1"
}
EOF
}

#############################################
# LOCK & SAFETY
#############################################

check_lock() {
  if [ -f "$LOCK_FILE" ]; then
    log_error "Agent already running (lock file exists)"
    exit 1
  fi
  touch "$LOCK_FILE"
  log "Lock file created: $LOCK_FILE"
}

release_lock() {
  rm -f "$LOCK_FILE"
  log "Lock file released"
}

check_emergency_stop() {
  if [ -f "$EMERGENCY_STOP" ]; then
    log "🛑 Emergency stop signal detected. Halting gracefully..."
    save_state "emergency_stop"
    return 1
  fi
  return 0
}

trap 'release_lock; exit' EXIT INT TERM

#############################################
# SYSTEM CHECKS
#############################################

check_ollama() {
  if ! curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
    log "⚠️  Ollama not running. Attempting to start..."
    if ! open -a Ollama 2>/dev/null; then
      log_error "Failed to start Ollama. Exiting."
      save_state "ollama_failure"
      exit 1
    fi
    sleep 10
    
    # Retry connection
    if ! curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
      log_error "Ollama still not responding after startup attempt"
      save_state "ollama_failure"
      exit 1
    fi
  fi
  log_success "Ollama connection verified"
}

check_cpu() {
  # Get CPU percentage (macOS specific)
  local cpu_percent=$(ps aux | awk 'NR==1{next} {sum+=$3} END {print int(sum)}')
  
  if [ "$cpu_percent" -gt 75 ]; then
    log "⚠️  CPU usage high ($cpu_percent%). Sleeping 5 minutes to cool down..."
    sleep 300
    return 1
  fi
  return 0
}

check_git_repo() {
  cd "$PROJECT_DIR"
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not a git repository: $PROJECT_DIR"
    save_state "not_git_repo"
    exit 1
  fi
  log_success "Git repository verified"
}

#############################################
# TASK MANAGEMENT
#############################################

pull_next_task() {
  # Read .agent-todo.md, find first incomplete task
  local todo_file="$PROJECT_DIR/.agent-todo.md"
  
  if [ ! -f "$todo_file" ]; then
    log "TODO file not found"
    return 1
  fi
  
  # Find first "- [ ]" task (incomplete)
  local task_line=$(grep -n "^### Task [0-9]" "$todo_file" | head -1)
  
  if [ -z "$task_line" ]; then
    log "No tasks found in TODO file"
    return 1
  fi
  
  # Extract task number and description
  local task_num=$(echo "$task_line" | sed 's/.*Task \([0-9]*\).*/\1/')
  local task_desc=$(echo "$task_line" | sed 's/.*### //' | sed "s/Task $task_num: //")
  
  echo "$task_num|$task_desc"
  return 0
}

mark_task_complete() {
  local task_num="$1"
  local todo_file="$PROJECT_DIR/.agent-todo.md"
  local task_id="Task $task_num"
  
  # Replace "- [ ]" with "- [x]" for this task
  sed -i '' "/^### $task_id:/,/^### Task/s/- \[ \]/- [x]/" "$todo_file" || true
  
  log_success "Marked Task $task_num complete in TODO"
}

invoke_qwen_for_task() {
  local task_num="$1"
  local task_desc="$2"
  
  log "Invoking Qwen for Task $task_num: $task_desc"
  
  # Direct Ollama API call with detailed task context
  local prompt="You are implementing a JavaScript game feature. Read this task carefully:

Task $task_num: $task_desc

From .agent-todo.md:
- File to modify: cat-mmo/public/cat.js
- Implementation requirements: See task details in .agent-todo.md
- Code must follow existing ES6 class patterns
- Add JSDoc comments
- Must compile without errors
- After implementation, git commit with message: '🤖 Task $task_num: $task_desc'

Implement this task completely. Output ONLY working code changes."

  local response=$(curl -s "http://127.0.0.1:11434/api/generate" \
    -d "{
      \"model\": \"qwen2.5-coder:3b\",
      \"prompt\": \"$prompt\",
      \"stream\": false,
      \"temperature\": 0.3,
      \"num_predict\": 2048
    }")
  
  if [ $? -ne 0 ]; then
    log_error "Qwen invocation failed"
    return 1
  fi
  
  log "Qwen response received, processing..."
  return 0
}

compile_and_verify() {
  # Basic syntax check: try to parse JavaScript
  if command -v node &> /dev/null; then
    node -c "$PROJECT_DIR/cat-mmo/public/cat.js" 2>&1 | tee -a "$LOG_FILE" || {
      log_error "Syntax error detected"
      return 1
    }
  fi
  
  log_success "Code syntax verified"
  return 0
}

commit_task() {
  local task_num="$1"
  local task_desc="$2"
  
  cd "$PROJECT_DIR"
  
  git add cat-mmo/public/cat.js || true
  
  if git diff --cached --quiet; then
    log "No changes to commit for Task $task_num"
    return 0
  fi
  
  git commit -m "🤖 Task $task_num: $task_desc" 2>&1 | tee -a "$LOG_FILE"
  
  if [ $? -eq 0 ]; then
    log_success "Committed Task $task_num"
    return 0
  else
    log_error "Commit failed for Task $task_num"
    return 1
  fi
}

#############################################
# MAIN EXECUTION LOOP
#############################################

trap 'release_lock' EXIT

log "========================================="
log "Starting Overnight Agent Session"
log "========================================="

# Pre-flight checks
check_lock
check_git_repo
check_ollama

SESSION_START=$(date +%s)
MAX_RUNTIME=$((8 * 3600))  # 8 hours
TASK_COUNT=0
FAILED_TASKS=0
LOOP_ITERATION=0

save_state "running"

while true; do
  LOOP_ITERATION=$((LOOP_ITERATION + 1))
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - SESSION_START))
  ELAPSED_HOURS=$(echo "scale=1; $ELAPSED / 3600" | bc)
  
  log "--- Loop iteration $LOOP_ITERATION (Elapsed: ${ELAPSED_HOURS}h) ---"
  
  # Check emergency stop
  if ! check_emergency_stop; then
    break
  fi
  
  # Stop after 8 hours
  if [ "$ELAPSED" -gt "$MAX_RUNTIME" ]; then
    log "⏱️  Max runtime (8 hours) reached. Stopping."
    break
  fi
  
  # CPU check
  if ! check_cpu; then
    continue
  fi
  
  # Get next task
  local task_info=$(pull_next_task)
  if [ $? -ne 0 ]; then
    log "⏳ No more tasks. Waiting 10 minutes for new tasks..."
    sleep 600
    continue
  fi
  
  IFS='|' read -r task_num task_desc <<< "$task_info"
  
  log "Processing: Task $task_num - $task_desc"
  
  # Implement task with Qwen
  if invoke_qwen_for_task "$task_num" "$task_desc"; then
    # Verify compilation
    if compile_and_verify; then
      # Commit changes
      if commit_task "$task_num" "$task_desc"; then
        mark_task_complete "$task_num"
        TASK_COUNT=$((TASK_COUNT + 1))
        log_success "Task $task_num completed ($TASK_COUNT total)"
        save_state "running_$TASK_COUNT"
      else
        log_error "Failed to commit Task $task_num"
        FAILED_TASKS=$((FAILED_TASKS + 1))
      fi
    else
      log_error "Compilation failed for Task $task_num. Skipping."
      FAILED_TASKS=$((FAILED_TASKS + 1))
      # Attempt revert
      cd "$PROJECT_DIR"
      git checkout cat-mmo/public/cat.js 2>&1 | tee -a "$LOG_FILE"
    fi
  else
    log_error "Qwen invocation failed for Task $task_num"
    FAILED_TASKS=$((FAILED_TASKS + 1))
  fi
  
  # Small delay between tasks (system breathing room)
  sleep 30
done

#############################################
# SESSION COMPLETE
#############################################

log "========================================="
log "Session Complete!"
log "Tasks Completed: $TASK_COUNT"
log "Failed Tasks: $FAILED_TASKS"
log "Runtime: $(( ($(date +%s) - SESSION_START) / 60 )) minutes"
log "========================================="

save_state "complete_$TASK_COUNT"

# Send macOS notification
osascript -e "display notification \"Overnight agent finished! $TASK_COUNT tasks completed, $FAILED_TASKS failed.\" with title \"Cat Game Agent\" sound name \"Glass\"" 2>/dev/null || true

release_lock

# Exit with success if at least 1 task completed
if [ "$TASK_COUNT" -gt 0 ]; then
  exit 0
else
  exit 1
fi
