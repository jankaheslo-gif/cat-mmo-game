# Agent Task Validator Framework
## Ensuring Clear, Unambiguous Tasks for Qwen2.5-Coder 3B

This document defines the template and validation checklist for all tasks in `.agent-todo.md`. Tasks must pass this framework to prevent Qwen from guessing intent.

---

## Task Template

Every task MUST follow this structure to be executable:

```markdown
### [TASK_ID] [TITLE]
**Estimated Time**: 20-40 minutes
**Complexity**: Beginner | Intermediate | Advanced
**File(s) Modified**: path/to/file.js (lines X-Y)
**Dependencies**: Task 1, Task 2 (list prior tasks)

#### Description
One-paragraph explanation of what needs to be done and why.

#### Acceptance Criteria
- [ ] Criterion 1: Specific, measurable outcome (e.g., "function returns true when...")
- [ ] Criterion 2: Can be verified by code inspection or test run
- [ ] Criterion 3: Include edge cases (e.g., "handles negative values")

#### Code Context
\`\`\`javascript
// Lines from cat.js where changes will happen
// Include 5+ lines for reference
\`\`\`

#### Implementation Hints
- Hint 1: Reference existing pattern in codebase
- Hint 2: Specific line numbers or function names to modify
- Hint 3: JSDoc format or naming convention to follow

#### Rollback Plan
If compilation fails or behavior breaks, revert with:
\`\`\`bash
git revert HEAD --no-edit
\`\`\`

#### Testing
- [ ] Code compiles: `npm run build` (or equivalent)
- [ ] No linting errors in modified files
- [ ] If game-logic related: Verify in browser console for errors
```

---

## Validation Checklist

Before adding task to `.agent-todo.md`, verify ALL of these:

- [ ] **Task Size**: 20-40 minutes of focused work (not too big, not too small)
- [ ] **Specific Files**: Exact file paths given (e.g., `cat-mmo/public/cat.js` not "game file")
- [ ] **Line Numbers**: Reference to existing code lines for context
- [ ] **Acceptance Criteria**: Each criterion is testable (not "looks good" but "returns X")
- [ ] **No Ambiguity**: Any animation name used matches existing names in code
- [ ] **Dependencies Clear**: If task depends on previous tasks, it's listed
- [ ] **Rollback Plan**: Clear git command if task fails
- [ ] **Code Pattern Match**: Follows existing style (JSDoc, ES6 classes, camelCase, etc.)
- [ ] **No External APIs**: Task uses only local code, no API calls needed
- [ ] **Testing Step Included**: How to verify the task was done correctly

---

## Cat Game 2.1 Code Patterns

Tasks must reference these existing patterns:

### JSDoc Format
```javascript
/**
 * Plays animation clip by name.
 * @param {string} clipName - Name of the animation clip (e.g., 'walk', 'run', 'jump_start')
 * @param {number} speed - Animation playback speed multiplier
 * @returns {boolean} true if animation played, false if clip not found
 */
playAnimation(clipName, speed = 1.0) {
  // implementation
}
```

### State Management Pattern
```javascript
// Cat state object (do not modify structure)
cat = {
  position: { x, y, z },
  velocity: { x, y, z },
  jumpPhase: 'none' | 'starting' | 'falling' | 'ending', // animation state
  isAttacking: boolean,
  isJumping: boolean,
  isCrouching: boolean,
  vitality: number,
  // ... other properties
}
```

### Animation Flow Example
```javascript
// Jump animation sequence:
// 1. Jump key pressed → jumpPhase = 'starting' → play 'jump_start' clip
// 2. 0.3s cooldown enforced with lastJumpAnimTime
// 3. Cat leaves ground → jumpPhase = 'falling' (may play 'jump_air' if available)
// 4. Cat lands → jumpPhase = 'ending' → play 'jump_end' clip (must wait 0.3s)
// 5. jumpPhase = 'none' after landing anim completes
```

### Naming Conventions
- Animation clips: lowercase_with_underscores (e.g., `jump_start`, `run`, `attack_paw`)
- Variables: camelCase (e.g., `lastJumpAnimTime`, `jumpEndTimer`)
- Constants: UPPERCASE_WITH_UNDERSCORES (e.g., `JUMP_COOLDOWN_MS = 300`)
- Functions: camelCase, verb first (e.g., `playAnimation()`, `checkCollision()`)

---

## Common Issues to Avoid

| ❌ Bad | ✅ Good |
|-------|--------|
| "Fix the jump" | "Implement jump_start animation on jump key press, enforce 300ms cooldown using lastJumpAnimTime" |
| "Make death work" | "Add death state when vitality ≤ 0, lock movement, play 'death' animation, disable input" |
| "Update animation" | "In updateCatAnimation(), change line 847 to check jumpPhase before calling playAnimation()" |
| No file path | "File: cat-mmo/public/cat.js, lines 840-860" |
| No acceptance criteria | "Criteria: Function returns boolean; handles null input; animation plays smoothly" |

---

## Example: Good Task

### Task 1: Implement Jump Start Animation Gate
**Estimated Time**: 30 minutes
**Complexity**: Intermediate
**File(s) Modified**: `cat-mmo/public/cat.js` (lines 840-920)
**Dependencies**: None (core jump system)

#### Description
Implement animation gating for jump start so that jump_start plays exactly once per jump, protected by a 300ms cooldown. Currently, repeated jump presses may trigger jump_start multiple times without waiting for the animation to complete.

#### Acceptance Criteria
- [ ] `lastJumpAnimTime` is checked before playing jump_start animation
- [ ] 300ms cooldown enforced: `Date.now() - lastJumpAnimTime > 300`
- [ ] jump_start does not play if jumpPhase is not 'none'
- [ ] If fallback (no clip), manual frame animation still respects cooldown
- [ ] Pressing jump quickly twice only plays jump_start once

#### Code Context
```javascript
// Lines 840-860: Current jump input handler
if (keys['w'] && !this.lastJumpPressed) {
  this.lastJumpPressed = true;
  this.jumpPhase = 'starting';
  // TODO: Add cooldown check here
  this.cat.playAnimation('jump_start');
}
```

#### Implementation Hints
- Use `Date.now()` to track time: `this.lastJumpAnimTime = Date.now()`
- Check at line 842: `if (Date.now() - this.lastJumpAnimTime > 300)`
- Pattern already used in other animations; follow existing style at line 755
- JSDoc format: add @param for any new helper functions

#### Rollback Plan
```bash
git diff HEAD~1 cat-mmo/public/cat.js # verify only jump logic changed
git revert HEAD --no-edit
```

#### Testing
- [ ] npm run build completes without errors
- [ ] Open cat game in browser, press jump repeatedly, verify jump_start plays once
- [ ] Check console for no animation errors
- [ ] Verify other animations (walk, run) still work normally

---

## Task Validation Workflow

1. **Draft task** using template above
2. **Self-check** against validation checklist (9 items)
3. **Reference code** in cat.js to verify file paths & line numbers are correct
4. **Estimate time**: Get a feel by looking at code complexity
5. **Add to `.agent-todo.md`**: Copy to TODO file when all checks pass
6. **Mark in agent-todo**: `- [ ] Task description`
7. **During execution**: Qwen reads task, implements, tests, commits
8. **Review morning**: Verify code quality before merging to main

