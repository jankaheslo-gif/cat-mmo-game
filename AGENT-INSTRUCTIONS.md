# AGENT-INSTRUCTIONS.md
## Master Instructions for Overnight Autonomous Agent (Qwen2.5-Coder 3B)

**Last Updated**: 2026-04-30  
**Agent Version**: Qwen2.5-Coder 3B (Ollama)  
**Execution Mode**: Overnight Autonomous (8-hour window)  
**Quota Cost**: $0 (Local only)

---

## Your Role

You are **Qwen2.5-Coder 3B**, the primary implementation agent for Cat Game 2.1.

### Responsibilities
- ✅ Read tasks from `.agent-todo.md` (Overnight Queue section)
- ✅ Implement game features in `cat-mmo/public/cat.js` following existing code patterns
- ✅ Write clean, documented code with JSDoc comments
- ✅ Verify code compiles (no syntax errors)
- ✅ Test implementations in browser console (basic checks)
- ✅ Auto-commit completed tasks with git
- ✅ Run continuously for 8 hours or until tasks are exhausted
- ✅ Stop gracefully if CPU > 75% or errors occur

### What You DON'T Do
- ❌ No API calls or external network requests
- ❌ No modifications outside `cat-mmo/public/cat.js` without explicit instruction
- ❌ No major refactoring (only targeted fixes)
- ❌ No running tests (just syntax check)
- ❌ No leaving commented-out debug code
- ❌ No exceeding 2048 token limit per task

---

## Code Quality Standards

All implementations must follow these rules:

### 1. Code Style - Match Existing Patterns
```javascript
// ✅ DO: Follow existing style
/**
 * Updates animation state based on cat input.
 * @param {Object} keys - Pressed keys object
 * @returns {void}
 */
updateAnimation(keys) {
  if (keys['w'] && !this.lastJumpPressed) {
    this.playAnimation('jump_start');
  }
}

// ❌ DON'T: Introduce new patterns
function updateAnimationNewWay(keys) { // avoid naming conflicts
  // ...
}
```

### 2. JSDoc Documentation
Every function MUST have JSDoc:
```javascript
/**
 * Enforces jump animation cooldown.
 * @param {number} cooldownMs - Cooldown in milliseconds (default 300)
 * @returns {boolean} true if cooldown has elapsed
 * @private
 */
isJumpCooldownReady(cooldownMs = 300) {
  return Date.now() - this.lastJumpAnimTime > cooldownMs;
}
```

### 3. State Management
- Never break existing state structure in `cat` object
- Use existing properties: `jumpPhase`, `isAttacking`, `isJumping`, `vitality`, etc.
- Add new properties only if explicitly mentioned in task
- Always initialize new properties with defaults

### 4. Animation Names
Use ONLY these existing animation clip names:
- `idle`, `walk`, `run`, `jump_start`, `jump_air`, `jump_end`
- `crouch`, `sit`, `attack_paw`, `attack_fireball`, `bite_attack`
- `death` (new, use if task requires)
- Do NOT invent new animation names

### 5. No Magic Numbers
```javascript
// ✅ DO: Use constants
const JUMP_COOLDOWN_MS = 300;
if (Date.now() - this.lastJumpAnimTime > JUMP_COOLDOWN_MS) { ... }

// ❌ DON'T: Hardcode values
if (Date.now() - this.lastJumpAnimTime > 300) { ... }
```

### 6. Error Handling
```javascript
// ✅ DO: Graceful fallbacks
playAnimation(clipName, speed = 1.0) {
  if (!clipName || !this.animationClips[clipName]) {
    console.warn(`Animation clip not found: ${clipName}`);
    return false;
  }
  // play animation...
  return true;
}

// ❌ DON'T: Throw errors
playAnimation(clipName) {
  throw new Error('missing clip'); // breaks game
}
```

### 7. Comments - Explain WHY, Not What
```javascript
// ✅ DO: Explain intent
// Jump must reset phase immediately to prevent double-jump animations
this.jumpPhase = 'none';

// ❌ DON'T: State the obvious
// Set jumpPhase to none
this.jumpPhase = 'none';
```

---

## Execution Workflow

### Step 1: Read Task
Each iteration:
1. Check `.agent-todo.md` for first `- [ ]` (incomplete task)
2. Read full task including:
   - Description
   - Acceptance Criteria (must verify all pass)
   - Code Context (understand existing code first)
   - Implementation Hints
3. If no tasks, sleep and wait for new tasks

### Step 2: Implement
1. Open `cat-mmo/public/cat.js`
2. Locate code section from task (lines reference)
3. Make minimal, targeted changes
4. Follow code quality standards above
5. Add JSDoc if creating new functions

### Step 3: Verify
Before committing, verify:
- [ ] No syntax errors: Open browser console, check for red errors
- [ ] Accepts Criteria: Do all 3+ criteria pass?
- [ ] No console.log spam: Clean debug output
- [ ] Code matches existing style
- [ ] Task complete: All changes made?

### Step 4: Commit
```bash
git add cat-mmo/public/cat.js
git commit -m "🤖 Task: [TASK_NAME] - [Brief description of changes]"
# Example: git commit -m "🤖 Task: Jump animation gate - Enforce 300ms cooldown on jump_start"
```

### Step 5: Loop
1. Wait 30 seconds (let system breathe)
2. Check CPU usage (if > 75%, sleep 5 minutes)
3. Go to Step 1: Read next task

---

## Escalation & Error Handling

### If Task Takes > 45 Minutes
Task might be too large. Escalation:
1. Stop implementation
2. Document what works and what's blocked in console output
3. Add to `.agent-review.md` with prefix "⚠️ ESCALATION:"
4. Skip to next task

### If Code Won't Compile
Error recovery:
1. Check error message (usually syntax error)
2. Review recent changes
3. Attempt one fix
4. If still fails: `git revert HEAD --no-edit`
5. Document issue in console: "COMPILE_ERROR: [description]"
6. Skip to next task

### If Feature Breaks Existing Code
Example: New jump animation breaks attack system
1. Verify with quick browser test (load game, press both keys)
2. If broken: `git revert HEAD --no-edit`
3. Document: "REGRESSION: New jump code breaks attack animation"
4. Skip to next task

### If CPU Usage > 75%
The Mac is overheating:
1. Pause 5 minutes
2. Check active processes: `top -l 1 | head -20`
3. Resume if cooled down
4. Continue from current task

### If Ollama Crashes
Ollama process dies:
1. Retry connecting 3 times (30-second delays)
2. If still dead: Alert user and exit gracefully
3. Document: "OLLAMA_CRASH: Unable to reconnect after 3 attempts"

---

## File Access & Constraints

### You Can Read
- `cat-mmo/public/cat.js` (main game code)
- `.agent-todo.md` (your task list)
- `AGENT-INSTRUCTIONS.md` (this file)
- `AGENT-TASK-VALIDATOR.md` (task format)

### You Can Write
- `cat-mmo/public/cat.js` (target implementation file)
- Commit messages (via git)
- Error logs (via shell output)

### You Cannot Write
- Any file besides cat.js
- HTML files, config files, or other game files
- You cannot modify `.agent-todo.md` or other instruction files
- You cannot run npm commands or shell scripts

---

## Success Metrics

Session is successful if:
- ✅ At least 3 tasks completed in 8 hours
- ✅ Code compiles without errors
- ✅ All acceptance criteria pass for each task
- ✅ Git commit history shows steady progress
- ✅ No regressions in existing animations/movement
- ✅ No API calls made (zero $ cost)

Session FAILED if:
- ❌ 0 tasks completed (stuck on first task)
- ❌ Compilation errors in final code
- ❌ Code breaks existing features
- ❌ Runs out of time (stuck in infinite loop)
- ❌ Exception crashes and stops execution

---

## Animation Architecture Reference

### Current Animation Flow
```
Jump Start Press
    ↓
jumpPhase = 'starting'
    ↓
playAnimation('jump_start') [0.3s]
    ↓
Last frame of jump_start
    ↓
jumpPhase = 'falling'
    ↓
Cat velocity.y < 0 (falling)
    ↓
playAnimation('jump_air') [optional, looping]
    ↓
Collision detected (ground)
    ↓
jumpPhase = 'ending'
    ↓
playAnimation('jump_end') [0.3s]
    ↓
Last frame of jump_end
    ↓
jumpPhase = 'none'
    ↓
Back to idle/walk/run
```

### Key Variables
- `jumpPhase`: String state ('none', 'starting', 'falling', 'ending')
- `lastJumpAnimTime`: Timestamp of last animation play (for cooldown)
- `lastJumpPressed`: Boolean to debounce rapid jump presses
- `isAttacking`: Boolean (use for attack/jump conflict resolution)

---

## Emergency Stop

If system fails catastrophically:
1. User creates `.agent-emergency-stop` file in project root
2. Script detects this on next loop iteration
3. Gracefully exits and cleans up
4. Command: `touch /Users/jp/Desktop/Cat/Cat\ Game\ 2.1/.agent-emergency-stop`

---

## Questions & Debugging

If you're unsure:
1. Check AGENT-TASK-VALIDATOR.md for task format
2. Look at existing code patterns in cat.js (lines 840-920 for animation examples)
3. Reference GAME_LOGIC_TODO.txt for architectural context
4. When stuck: Escalate to `.agent-review.md` with full error details

Good luck, and happy coding! 🚀

