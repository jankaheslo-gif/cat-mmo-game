# WORKFLOW-EXAMPLE.md
## Example: How the Multi-Agent System Works

This document walks through a complete 24-hour cycle showing how Qwen (coder), Tencent (planner), and NVIDIA (reviewer) work together.

---

## Scenario: Adding Jump Feature to Cat Game

### Day 1: Morning (10 AM) - Planning Phase

**You decide**: "I want to add a jump mechanic to the cat."

**You invoke**: Planner (Tencent Hy3)
```bash
# In Continue chat:
@planner analyze "Add jump mechanic with proper animation sequence and cooldown gating"
```

**Tencent Output** (5 minutes, ~$0.01 cost):
```
## Jump Feature Implementation Plan

### Analysis
The jump mechanic requires:
- Animation state management (jump_start → jump_air → jump_end)
- Physics integration (velocity, gravity)
- Cooldown protection (300ms between animations)
- Conflict resolution (cannot jump while attacking)

### Implementation Breakdown

**Phase 1: Animation Logic (2-3 hours)**
1. [ ] Task 1: Implement jump_start animation gate with 300ms cooldown
2. [ ] Task 2: Add jump_end animation on landing
3. [ ] Task 3: Enforce single jumpStart/jumpEnd per sequence

**Phase 2: Stability (1 hour)**
4. [ ] Task 4: Verify attack/jump don't conflict
5. [ ] Task 5: Test crouch + jump interaction

**Phase 3: Documentation (30 min)**
6. [ ] Task 6: Document control scheme
7. [ ] Task 7: Add architecture notes

### Risk Assessment
- Risk: Animating while attacking → visual glitch
- Mitigation: Add state guard in animation priority
- Effort: ~4-5 hours total
- Priority: Core gameplay (HIGH)

### Recommended Order
1. Implement Task 1-3 (animation system)
2. Test Task 4-5 (stability)
3. Document Task 6-7
```

**Result**: Tasks 1-7 added to `.agent-todo.md`

---

### Day 1: Afternoon (2 PM) - Task Validation

**You check**: Are all tasks clear and unambiguous?

**You review**: `.agent-todo.md` against `AGENT-TASK-VALIDATOR.md`

Each task verified:
- ✅ Task 1: Clear file path (cat.js lines 840-900), specific acceptance criteria (jump_start plays once)
- ✅ Task 2: Clear landing detection, specific animation trigger
- ✅ Task 3: Clear counter tracking, state reset logic
- ✅ Tasks 4-7: All formatted correctly

**Result**: All tasks pass validation. Ready for overnight run.

---

### Day 1: Evening (10 PM) - Overnight Automation Begins

**You prepare**:
```bash
cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1

# Verify setup
./scripts/test-qwen.sh                    # Verify Ollama connection
./scripts/validate-tasks.sh               # Final task validation

# Launch overnight session (optional manual start, or wait for cron at 10 PM)
./scripts/overnight-agent.sh > logs/manual-start.log 2>&1 &
```

**Log output**:
```
[2026-04-30 22:00:00] ========================================
[2026-04-30 22:00:00] Starting Overnight Agent Session
[2026-04-30 22:00:00] ========================================
[2026-04-30 22:00:00] Ollama connection verified
[2026-04-30 22:00:00] Git repository verified
[2026-04-30 22:00:00] --- Loop iteration 1 ---
[2026-04-30 22:00:05] Processing: Task 1 - Implement Jump Start Animation Gate
[2026-04-30 22:00:10] Invoking Qwen for Task 1
[2026-04-30 22:00:35] Qwen response received
[2026-04-30 22:00:40] Code syntax verified
[2026-04-30 22:00:45] ✅ Committed Task 1
[2026-04-30 22:00:50] Marked Task 1 complete in TODO
[2026-04-30 22:01:20] --- Loop iteration 2 ---
[2026-04-30 22:01:25] Processing: Task 2 - Jump End Animation on Landing
...
```

**What Qwen does** (overnight, 10 PM - 6 AM):
1. Reads Task 1 from `.agent-todo.md`
2. Generates code: Jump start animation gate with 300ms cooldown
3. Verifies syntax: No JavaScript errors
4. Commits to git: `🤖 Task 1: Implement Jump Start Animation Gate`
5. Marks Task 1 as `[x]` in TODO
6. Sleeps 30 seconds
7. Repeats for Tasks 2-7

**Expected result**: 5-6 tasks completed overnight, code committed, ready for morning review.

---

### Day 2: Morning (6 AM) - Review Phase

**You wake up, review overnight results**:

```bash
cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1

# Check overnight logs
tail -100 logs/overnight-2026-04-30_22-00-00.log

# Review commits
git log --oneline -20

# Output:
# 🤖 Task 7: Architecture Notes & Documentation
# 🤖 Task 6: Control Documentation & README
# 🤖 Task 5: Crouch Animation Logic Verification
# 🤖 Task 4: Prevent Backward Running
# 🤖 Task 3: Enforce Single jumpStart/jumpEnd
# 🤖 Task 2: Jump End Animation on Landing
# 🤖 Task 1: Implement Jump Start Animation Gate
# Main development branch
```

**Manual testing** (open game in browser):
```javascript
// Open browser console while playing
// Test 1: Press jump once → jump_start plays once ✅
// Test 2: Press jump 5 times rapidly → jump_start plays once, waits ✅
// Test 3: Jump → land → jump again → smooth sequence ✅
// Test 4: Walk backward + shift → stays walk speed (no run) ✅
// Test 5: Reduce vitality to 0 → death animation plays ✅
```

**All tests pass!** Time to invoke Reviewer for final audit.

---

### Day 2: Morning (7 AM) - Code Review

**You invoke**: Reviewer (NVIDIA Nemotron)
```bash
# In Continue chat:
@reviewer audit "Jump feature implementation (Tasks 1-7), verify code quality and edge cases"
```

**NVIDIA Output** (10 minutes, ~$0.01 cost):
```
## Code Review: Jump Feature Implementation

### 📊 Overall Assessment
- **Code Quality**: Excellent (8.5/10)
- **Test Coverage**: Good (7/10)
- **Documentation**: Excellent (9/10)
- **Performance**: Good (7.5/10)

### ✅ Strengths
1. Clean state machine implementation
2. Proper JSDoc comments
3. Consistent with existing code style
4. Good error handling
5. Minimal edge cases

### 🟡 Warnings
1. **Animation clip caching**: Currently looks up 'jump_start' clip by name every frame. Could cache reference during init for performance.
   - Recommendation: Store `this.jumpStartClip` in constructor
   - Impact: Minor (2-3% FPS improvement possible)

2. **Cooldown logic**: Hardcoded 300ms. Consider making configurable.
   - Current: `const JUMP_COOLDOWN_MS = 300;`
   - Could improve: Read from config file (cat-mmo/config/stats.js)

3. **Edge case**: Rapid crouch + jump interaction not tested
   - Current: Code blocks jump while crouching ✅
   - Should verify: Can't double-jump by crouch-toggle spam

### 🟢 Suggestions
1. Add performance profiling to measure jump animation impact
2. Consider adding telemetry for jump success rate (useful for multiplayer balance)
3. Document expected jump height/distance in comments

### ✅ APPROVAL STATUS
**Conditional Approval**: Merge with optional performance optimization

The code is production-ready. Suggest addressing warning #1 (animation caching) in next sprint for performance.

### Recommended Next Steps
- [ ] Merge to main branch
- [ ] Deploy to production
- [ ] Monitor for user feedback (jump feel, responsiveness)
- [ ] Optional: Performance optimization sprint next week
```

**Result**: Code approved! Minor performance suggestions, no blocking issues.

---

### Day 2: Mid-Morning (8 AM) - Merge to Production

```bash
cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1

# Final verification
npm run build          # Full build test
npm run test           # Run test suite

# Merge and deploy
git checkout main
git merge overnight-dev
git push origin main   # Deploy!

# Cleanup
git branch -d overnight-dev
```

**Summary**:
- ✅ 7 tasks completed overnight (4-5 hours of work)
- ✅ All tests pass
- ✅ Code approved by NVIDIA reviewer
- ✅ Deployed to production
- 💰 Total cost: ~$0.02 (two API calls, both free tier)
- ⏱️ Total time investment: 15 minutes (review + approval)

---

### Day 2: Afternoon (2 PM) - Next Planning Cycle

**You gather feedback**:
- "Jump feels responsive!"
- "Cooldown is smooth"
- "Jump works mid-strafe"

**You prepare next sprint**:
```bash
# Remaining tasks from GAME_LOGIC_TODO.txt:
# - Tail animation (deferred, low priority)
# - Attack system improvements
# - Performance optimization

# Invoke Planner to prioritize next work
@planner prioritize "Tail animation (deferred), Attack system improvements, Performance optimization"
```

**Tencent Output**:
```
## Next Sprint Priority

1. **Attack System Improvements** (HIGH) - 3 hours
   - Extend combo system
   - Add cooldown between attacks
   - Prevent double-attack glitch

2. **Performance Optimization** (MEDIUM) - 2 hours
   - Cache animation clips (as suggested by reviewer)
   - Profile rendering bottlenecks

3. **Tail Animation** (LOW) - Defer to next week
   - Complex, low priority
   - Implement only if time permits
```

**Result**: Next sprint planned. Ready for next overnight cycle!

---

## Summary: What Happened

| Phase | Agent | Duration | Cost | Output |
|-------|-------|----------|------|--------|
| Morning Planning | Tencent | 5 min | $0.01 | 7 tasks broken down |
| Afternoon Validation | You | 15 min | $0 | Tasks validated |
| Overnight Implementation | Qwen | 8 hours | $0 | 7 tasks completed, committed |
| Morning Review | You | 10 min | $0 | Manual testing ✅ |
| Morning Audit | NVIDIA | 10 min | $0.01 | Code approved with suggestions |
| Deployment | You | 5 min | $0 | Merged to main |
| **Total** | **All** | **~30 min user time + 8 hours auto** | **~$0.02** | **7 features shipped!** |

---

## Key Takeaways

✅ **Efficiency**: 8 hours of coding work done autonomously overnight  
✅ **Quality**: Code reviewed and approved before deployment  
✅ **Cost**: Only $0.02 (two API calls on free tier)  
✅ **Visibility**: Clear handoff between agents at each stage  
✅ **Safety**: Emergency stop available, git history preserved  

**Next time**: Use this same pattern for next sprint!

