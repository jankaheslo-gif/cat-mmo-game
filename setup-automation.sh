#!/bin/bash
# setup-automation.sh - One-time setup for overnight automation

PROJECT_DIR="/Users/jp/Desktop/Cat/Cat Game 2.1"

echo "========================================="
echo "Setting up Overnight Automation"
echo "========================================="

# Step 1: Make scripts executable
echo "1️⃣ Making scripts executable..."
chmod +x "$PROJECT_DIR/scripts/overnight-agent.sh"
chmod +x "$PROJECT_DIR/scripts/test-qwen.sh"
chmod +x "$PROJECT_DIR/scripts/validate-tasks.sh"
echo "✅ Scripts are now executable"

# Step 2: Create logs directory
echo "2️⃣ Creating logs directory..."
mkdir -p "$PROJECT_DIR/logs"
echo "✅ Logs directory created"

# Step 3: Verify git repo
echo "3️⃣ Verifying git repository..."
cd "$PROJECT_DIR"
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "✅ Git repository verified"
else
  echo "❌ ERROR: Not a git repository. Initialize git first:"
  echo "   cd '$PROJECT_DIR' && git init"
  exit 1
fi

# Step 4: Test Ollama
echo "4️⃣ Testing Ollama connection..."
if curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
  echo "✅ Ollama is running and accessible"
else
  echo "⚠️  Ollama is not running. Start it with: open -a Ollama"
  echo "   Then run this script again."
  exit 1
fi

# Step 5: Display crontab instructions
echo ""
echo "========================================="
echo "5️⃣ Set Up Crontab for Automatic Scheduling"
echo "========================================="
echo ""
echo "To schedule overnight runs automatically:"
echo ""
echo "1. Open crontab editor:"
echo "   crontab -e"
echo ""
echo "2. Add this line to run script daily at 10 PM:"
echo "   0 22 * * * $PROJECT_DIR/scripts/overnight-agent.sh >> $PROJECT_DIR/logs/cron.log 2>&1"
echo ""
echo "3. Verify it was added:"
echo "   crontab -l | grep overnight-agent"
echo ""
echo "(Or run './scripts/overnight-agent.sh' manually to test first)"
echo ""

# Step 6: Create helper aliases
echo "6️⃣ Setting up shell aliases..."
echo ""
echo "Add these to your ~/.zshrc for quick access:"
echo ""
cat << 'EOF'
# Cat Game 2.1 Agent Aliases
alias cat-agent-start='cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1 && ./scripts/overnight-agent.sh'
alias cat-agent-validate='cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1 && ./scripts/validate-tasks.sh'
alias cat-agent-test-qwen='cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1 && ./scripts/test-qwen.sh'
alias cat-agent-logs='tail -f /Users/jp/Desktop/Cat/Cat\ Game\ 2.1/logs/*.log'
alias cat-agent-stop='touch /Users/jp/Desktop/Cat/Cat\ Game\ 2.1/.agent-emergency-stop'
alias cat-agent-status='cat /Users/jp/Desktop/Cat/Cat\ Game\ 2.1/.agent-state.json | jq .'
EOF

echo ""
echo "Add these aliases with: cat ~/.zshrc | tail -20 >> ~/.zshrc"
echo ""

# Step 7: Display status
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Quick Start Guide:"
echo "1. Test Qwen connection:"
echo "   ./scripts/test-qwen.sh"
echo ""
echo "2. Validate tasks:"
echo "   ./scripts/validate-tasks.sh"
echo ""
echo "3. Run overnight agent (manual):"
echo "   ./scripts/overnight-agent.sh"
echo ""
echo "4. Or set up crontab for automatic 10 PM daily runs"
echo ""
echo "5. Check logs:"
echo "   tail -f ./logs/overnight-*.log"
echo ""
echo "Emergency stop:"
echo "   touch ./.agent-emergency-stop"
echo ""
echo "Status:"
echo "   cat .agent-state.json | jq ."
echo ""
echo "========================================="
