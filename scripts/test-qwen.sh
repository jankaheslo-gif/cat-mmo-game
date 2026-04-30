#!/bin/bash
# test-qwen.sh - Single-task dry-run to verify Qwen connection & basic functionality

PROJECT_DIR="/Users/jp/Desktop/Cat/Cat Game 2.1"
LOG_FILE="$PROJECT_DIR/logs/test-qwen-$(date +%Y-%m-%d_%H-%M-%S).log"

mkdir -p "$PROJECT_DIR/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Testing Qwen2.5-Coder Connection"
log "========================================="

# Check Ollama
log "Checking Ollama connection..."
if ! curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
  log "❌ Ollama not responding. Start Ollama and try again."
  exit 1
fi
log "✅ Ollama is online"

# Test Qwen with simple prompt
log "Sending test prompt to Qwen..."

TEST_PROMPT="Write a JavaScript function that returns true if a number is even. Include JSDoc comment. Only output the function code."

RESPONSE=$(curl -s "http://127.0.0.1:11434/api/generate" \
  -d "{
    \"model\": \"qwen2.5-coder:3b\",
    \"prompt\": \"$TEST_PROMPT\",
    \"stream\": false,
    \"temperature\": 0.3,
    \"num_predict\": 512
  }")

if [ -z "$RESPONSE" ]; then
  log "❌ No response from Qwen"
  exit 1
fi

echo "$RESPONSE" >> "$LOG_FILE"

log "✅ Qwen responded successfully"
log "Response preview:"
echo "$RESPONSE" | head -10 | tee -a "$LOG_FILE"

log "========================================="
log "Test complete! Ready for overnight run."
log "Log saved to: $LOG_FILE"
log "========================================="
