#!/bin/bash
# validate-tasks.sh - Verify .agent-todo.md tasks meet quality standards

PROJECT_DIR="/Users/jp/Desktop/Cat/Cat Game 2.1"
TODO_FILE="$PROJECT_DIR/.agent-todo.md"
VALIDATION_LOG="$PROJECT_DIR/logs/validation-$(date +%Y-%m-%d_%H-%M-%S).log"

mkdir -p "$PROJECT_DIR/logs"

VALID_TASKS=0
INVALID_TASKS=0

log() {
  echo "$1" | tee -a "$VALIDATION_LOG"
}

check_task() {
  local task_num="$1"
  local task_section="$2"
  
  log ""
  log "Validating Task $task_num..."
  
  local checks_passed=0
  local total_checks=8
  
  # Check 1: Has description
  if grep -q "#### Description" <<< "$task_section"; then
    ((checks_passed++))
    log "  ✅ Has description"
  else
    log "  ❌ Missing description"
  fi
  
  # Check 2: Has acceptance criteria
  if grep -q "#### Acceptance Criteria" <<< "$task_section"; then
    ((checks_passed++))
    log "  ✅ Has acceptance criteria"
  else
    log "  ❌ Missing acceptance criteria"
  fi
  
  # Check 3: Has code context
  if grep -q "#### Code Context" <<< "$task_section"; then
    ((checks_passed++))
    log "  ✅ Has code context"
  else
    log "  ❌ Missing code context"
  fi
  
  # Check 4: Has implementation hints
  if grep -q "#### Implementation Hints" <<< "$task_section"; then
    ((checks_passed++))
    log "  ✅ Has implementation hints"
  else
    log "  ❌ Missing implementation hints"
  fi
  
  # Check 5: Has rollback plan
  if grep -q "#### Rollback Plan" <<< "$task_section"; then
    ((checks_passed++))
    log "  ✅ Has rollback plan"
  else
    log "  ❌ Missing rollback plan"
  fi
  
  # Check 6: Has testing section
  if grep -q "#### Testing" <<< "$task_section"; then
    ((checks_passed++))
    log "  ✅ Has testing section"
  else
    log "  ❌ Missing testing section"
  fi
  
  # Check 7: Has file path reference
  if grep -q "File(s)" <<< "$task_section" || grep -q "file(s)" <<< "$task_section"; then
    ((checks_passed++))
    log "  ✅ Has file path reference"
  else
    log "  ❌ Missing file path reference"
  fi
  
  # Check 8: Estimated time between 20-40 minutes
  if grep -q "Estimated Time.*minutes" <<< "$task_section"; then
    local time=$(echo "$task_section" | grep "Estimated Time" | sed 's/.*Estimated Time[^0-9]*\([0-9]*\).*/\1/')
    if [ "$time" -ge 20 ] && [ "$time" -le 40 ]; then
      ((checks_passed++))
      log "  ✅ Reasonable time estimate ($time min)"
    else
      log "  ⚠️  Unusual time estimate ($time min, expected 20-40)"
    fi
  else
    log "  ❌ Missing time estimate"
  fi
  
  # Summary
  local percentage=$((checks_passed * 100 / total_checks))
  log "  Score: $checks_passed/$total_checks ($percentage%)"
  
  if [ "$checks_passed" -ge 7 ]; then
    ((VALID_TASKS++))
    log "  ✅ Task VALID"
    return 0
  else
    ((INVALID_TASKS++))
    log "  ❌ Task NEEDS REVIEW"
    return 1
  fi
}

log "========================================="
log "Task Validation Report"
log "========================================="
log "File: $TODO_FILE"
log "Date: $(date)"
log ""

if [ ! -f "$TODO_FILE" ]; then
  log "❌ TODO file not found: $TODO_FILE"
  exit 1
fi

# Extract all tasks
task_num=1
while [ $task_num -le 10 ]; do
  task_section=$(sed -n "/^### Task $task_num:/,/^### Task $((task_num + 1)):/p" "$TODO_FILE")
  
  if [ -z "$task_section" ]; then
    # Try to get last task
    task_section=$(sed -n "/^### Task $task_num:/,/^## /p" "$TODO_FILE")
  fi
  
  if [ -n "$task_section" ]; then
    check_task "$task_num" "$task_section"
  fi
  
  ((task_num++))
done

log ""
log "========================================="
log "Summary"
log "========================================="
log "Valid Tasks: $VALID_TASKS"
log "Tasks Needing Review: $INVALID_TASKS"
log "========================================="

if [ "$INVALID_TASKS" -gt 0 ]; then
  log "⚠️  Some tasks need review before overnight run"
  log "Review: $VALIDATION_LOG"
  exit 1
else
  log "✅ All tasks validated and ready for overnight run!"
  exit 0
fi
