# AGENT-ROLES.md
## Multi-Agent Hierarchy for Cat Game 2.1

**Overview**: Three specialized agents working together with clear handoff points. Primary work done locally (no API cost). Free tier reserved for high-value decisions only.

---

## Agent 1: Qwen2.5-Coder 3B (PRIMARY CODER)

**Model**: Ollama - Qwen2.5-Coder 3B (Local)  
**Status**: Always Available  
**API Cost**: $0 (Runs on your Mac)  
**Roles**: autocomplete, chat, coder  
**Usage Mode**: Autonomous (overnight) + Manual (during day)

### Primary Commands
- `@coder implement <task>` → Write code, implement feature
- `@coder debug <error>` → Fix bug or compilation error
- `@coder test <feature>` → Write unit tests, verify behavior
- `@coder review <file>` → Code review for quality/style

### Instructions
```
You are the Primary Developer for Cat Game 2.1.
- Implement tasks from .agent-todo.md overnight (8-hour sessions)
- Write clean, documented code in ES6 JavaScript
- Follow existing cat.js patterns (JSDoc, animation state machine, etc.)
- Include unit tests for new features
- Update .agent-todo.md with progress (mark [x] when done)
- You run locally with no API costs—unlimited usage!
- Escalate complex decisions to Reviewer (manual only)
```

### Advantages
✅ Unlimited usage (no quota)  
✅ Zero API costs  
✅ Fast response (local execution)  
✅ Offline capable (no internet needed)  
✅ Can run 8+ hours overnight  
✅ Low RAM footprint (3B model)

### Disadvantages
⚠️ Lower quality than larger models  
⚠️ Needs clear task descriptions (prone to ambiguity)  
⚠️ Single context window (can't track complex multi-file projects)  
⚠️ CPU-bound (will heat up Mac during intensive sessions)

### Overnight Automation
- Script: `scripts/overnight-agent.sh`
- Schedule: 10 PM daily via crontab
- Runtime: 8 hours max
- Safety: CPU throttling, error recovery, auto-commits
- Monitoring: Logs in `logs/` directory

### Rate Limits
None! Run as many times as you want. This is your primary dev agent.

---

## Agent 2: Tencent Hy3 Preview (PLANNER / STRATEGIST)

**Model**: OpenRouter - Tencent Hy3 preview (Free tier)  
**Status**: On-demand only (manual invocation)  
**API Cost**: Free (but quota-limited)  
**Roles**: planner  
**Usage Mode**: Manual only (expensive, save quota)

### Primary Commands
- `@planner analyze <feature>` → Strategic breakdown of new feature
- `@planner prioritize <list>` → Rank items by impact/effort
- `@planner design <system>` → Architecture recommendations
- `@planner refactor <code>` → Suggest refactoring approach

### Instructions
```
You are the Architect and Strategic Planner for Cat Game 2.1.
- Analyze feature requests holistically
- Break complex features into 2-4 hour implementation tasks
- Identify dependencies and risks upfront
- Output: Numbered, prioritized action items for the Coder
- Be concise (free tier quota is limited—$$ per call)
- Reference existing code patterns and architecture
- Tasks should be unambiguous (Qwen will implement them overnight)
```

### When to Use
1. **New Feature Planning**: Broken down into sub-tasks
2. **Architecture Decisions**: Should we refactor X?
3. **Dependency Analysis**: What breaks if we change Y?
4. **Priority Ranking**: What should we build first?

### When NOT to Use
- Daily development (use Qwen instead)
- Simple bugfixes (Qwen handles these)
- Code reviews (use Reviewer instead)
- Routine maintenance

### Rate Limits
**~10 API calls/day** on free tier  
**Recommended**: 1 planning session per 2 hours  
**Cost per call**: ~0.5¢ (minimal but adds up)

### Protection Strategy
- Use this agent sparingly—reserve for high-value decisions
- Plan entire sprint (1 week of tasks) in ONE session, not daily
- Reuse task breakdowns; don't re-plan same feature twice

---

## Agent 3: NVIDIA Nemotron 3 Super (REVIEWER / QA)

**Model**: OpenRouter - NVIDIA Nemotron 3 Super 120B (Free tier)  
**Status**: On-demand only (manual invocation)  
**API Cost**: Free (but quota-limited)  
**Roles**: reviewer  
**Usage Mode**: Manual only (expensive, save quota)

### Primary Commands
- `@reviewer audit <file>` → Code quality review
- `@reviewer test <feature>` → QA checklist, edge cases
- `@reviewer performance <code>` → Optimize suggestions
- `@reviewer security <code>` → Vulnerability check

### Instructions
```
You are the QA Lead and Code Reviewer for Cat Game 2.1.
- Review code from the Coder for quality, bugs, and edge cases
- Test game logic against expected behavior
- Identify performance bottlenecks
- Suggest optimizations for animation, physics, or rendering
- Output: Issues to .agent-review.md with priority (🔴 critical, 🟡 warning, 🟢 suggestion)
- Be thorough (free tier quota is limited but you provide high value)
```

### When to Use
1. **After overnight coding session**: Review all completed tasks
2. **Before major release**: Full code audit
3. **Performance issues**: Identify bottlenecks
4. **Edge case discovery**: Test unusual scenarios

### When NOT to Use
- Style fixes (Qwen can handle these)
- Routine linting (use automated tools)
- Trivial comments or documentation
- Every single commit (too expensive)

### Rate Limits
**~10 API calls/day** on free tier  
**Recommended**: 1 review session per 4 hours  
**Cost per call**: ~0.3¢ (cheaper than Planner)

### Protection Strategy
- Batch reviews: Review 3-5 completed tasks in ONE session
- Don't review partial work; wait until tasks are done
- Use for critical features only (gameplay, core loop)

---

## Handoff Process

### Daily Workflow (24-hour cycle)

**Evening (Before Overnight Run)**
```
1. You prepare: Add tasks to .agent-todo.md
2. Optionally invoke @planner to break down next sprint
3. Set up overnight session (scripts/overnight-agent.sh ready)
4. Go to bed
```

**Overnight (10 PM - 6 AM)**
```
1. Qwen runs autonomously for 8 hours
2. Reads .agent-todo.md, implements tasks
3. Commits after each task
4. Logs progress in logs/overnight-YYYY-MM-DD_HH-MM-SS.log
5. Stops after 8 hours or when tasks exhausted
```

**Morning (6 AM - 10 AM)**
```
1. You wake up, review overnight results
   - Check logs/ for any errors
   - Review git commits: git log --oneline -20
   - Verify code quality
2. Run full test suite (if applicable)
3. Optionally invoke @reviewer for code audit
4. Merge changes to main branch (or revert if issues)
5. Prepare new tasks for next overnight run
```

**Mid-Day (10 AM - 6 PM)**
```
1. Manual development time
2. Use @coder for interactive pair programming
3. Fix urgent bugs
4. Plan features with @planner if needed
5. Prepare high-value tasks for next overnight
```

---

## Monthly Quota Budget

| Agent | Model | Calls/Month | Cost | Use Case |
|-------|-------|------------|------|----------|
| Qwen | Local | ∞ | $0 | Daily dev, overnight automation |
| Tencent | Free tier | ~300 | ~$0.15 | 1 planning session per day |
| NVIDIA | Free tier | ~300 | ~$0.09 | 1 review session per 4 hours |
| **Total** | | | **~$0.24** | Minimal, sustainable cost |

---

## Real Example: Adding Jump Feature

### Step 1: Planning (Tencent - 5 min, 1 API call)

**You invoke**: `@planner analyze "Add jump mechanic with proper animation sequence"`

**Tencent Output**:
```
## Jump Feature Breakdown

### Phase 1: Animation Logic (Task 1-2, 1 hour)
1. [ ] Implement jump_start gate with 300ms cooldown
2. [ ] Add jump_end animation on landing

### Phase 2: Physics Integration (Task 3, 45 min)
3. [ ] Connect jump height to gravity system

### Phase 3: Testing (Task 4-5, 45 min)
4. [ ] Unit test: Jump triggers in all valid states
5. [ ] Regression test: Jump doesn't break attack animations

Priority: Core gameplay feature (high value)
Risk: May conflict with attack system (low risk)
Estimate: 3 hours total
```

**Result**: Tasks added to `.agent-todo.md`

---

### Step 2: Implementation (Qwen - Overnight 8 hours)

**You set up**: Overnight script runs 10 PM - 6 AM

**Qwen executes**:
```
[22:00] Session started
[22:05] Task 1: Implement jump_start gate
[22:35] ✅ Complete - commit: 🤖 Task: Jump animation gate
[22:40] Task 2: Add jump_end animation
[23:10] ✅ Complete - commit: 🤖 Task: Jump landing animation
[23:15] Task 3: Connect jump height to gravity
[23:50] ✅ Complete - commit: 🤖 Task: Jump physics integration
[23:55] Task 4: Unit test jump state machine
[00:25] ✅ Complete - commit: 🤖 Task: Jump test suite
[00:30] Task 5: Regression test attack/jump
[01:00] ✅ Complete - commit: 🤖 Task: Attack/jump conflict check
[01:05] No more tasks. Waiting...
[06:00] Timeout (8 hours). Session ended.
```

**Result**: 5 tasks done, code committed, ready for review

---

### Step 3: Review (NVIDIA - 10 min, 1 API call)

**You invoke**: `@reviewer audit "Jump feature implementation (tasks 1-5)"`

**NVIDIA Output**:
```
## Code Review: Jump Feature

✅ **Code Quality**: Excellent
- Proper JSDoc comments
- No magic numbers (uses constants)
- Follows existing animation patterns

🟡 **Performance**: Good but could optimize
- Jump animation playback could cache clip references
- Suggestion: Store `jumpStartClip` reference on init

🟢 **Testing**: Comprehensive
- All test cases covered
- Edge case: rapid spacebar press handled correctly

🔴 **CRITICAL ISSUE FOUND**
- Attack animation while jumping may play concurrently
- Risk: Visual glitch
- Fix: Add `isJumping` check to attack logic (line 1234)

**Approval**: Conditional on critical fix
```

**Result**: Issue identified, needs 1-2 hour fix (Qwen can handle next session)

---

## Summary: Agent Selection Guide

```
┌─────────────────────────────────────────────────────────────┐
│ Need to implement code?         → Qwen (primary coder)      │
│ Questions about architecture?   → Tencent (planner)         │
│ Need code quality audit?        → NVIDIA (reviewer)         │
│ Working solo on a feature?      → Qwen chat (pair program)  │
│ Planning sprint work?           → Tencent (once per week)   │
│ Before deployment/merge?        → NVIDIA (one full review)  │
│ Routine bugfixes?               → Qwen (fast, cheap)        │
│ Stuck on complex problem?       → Tencent + Qwen combo      │
└─────────────────────────────────────────────────────────────┘
```

