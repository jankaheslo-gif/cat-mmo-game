# WORKFLOW-PLAN.md

## Overview
This project uses a 24-hour workflow with three specialized roles:
- **Coder**: Implements tasks
- **Planner**: Breaks features into actionable tasks
- **Reviewer**: Audits completed work

The cycle:
- Plan during the day
- Validate tasks before overnight execution
- Run overnight automation for implementation
- Review results in the morning
- Repeat with new tasks

## Roles

### Coder
- Responsible for implementing work in `cat-mmo/public/cat.js`
- Works from `.agent-todo.md`
- Uses existing code style, state structure, and animation names
- Verifies syntax and browser behavior
- Commits each completed task
- Stops if CPU usage is too high or if the task is blocked

### Planner
- Responsible for breaking features into clear tasks
- Produces 20-40 minute work items
- Identifies dependencies and risks
- Keeps tasks unambiguous and actionable
- Uses validation rules before handing tasks to the Coder

### Reviewer
- Responsible for auditing completed work
- Checks code quality, edge cases, and performance
- Uses `.agent-review.md` for findings
- Reviews only finished tasks, not partial work
- Focuses on regressions, architecture, and behavior

## Task Template
Each task in `.agent-todo.md` should follow this structure:

```markdown
### [TASK_ID] [TITLE]
**Estimated Time**: 20-40 minutes  
**Complexity**: Beginner | Intermediate | Advanced  
**File(s) Modified**: `path/to/file.js` (lines X-Y)  
**Dependencies**: Task 1, Task 2

#### Description
One paragraph explaining what must be done and why.

#### Acceptance Criteria
- [ ] Criterion 1: Specific, measurable outcome
- [ ] Criterion 2: Can be verified by code inspection or test
- [ ] Criterion 3: Include edge cases

#### Code Context
```javascript
// Sample lines from the affected file
```

#### Implementation Hints
- Reference existing code patterns
- Specific function names or line ranges to modify
- JSDoc or naming conventions to follow

#### Rollback Plan
```bash
git revert HEAD --no-edit
```

#### Testing
- [ ] Code compiles
- [ ] No linting errors
- [ ] Browser verification if applicable
```

## Validation Checklist
Before adding a task to `.agent-todo.md`, verify:
- [ ] Task size is 20-40 minutes
- [ ] Exact file paths are given
- [ ] Line numbers or code context are referenced
- [ ] Acceptance criteria are testable
- [ ] No ambiguous wording
- [ ] Dependencies are clearly listed
- [ ] Rollback plan is provided
- [ ] Task follows existing code patterns
- [ ] Testing steps are included

Common patterns:
- Use JSDoc for new functions
- Preserve existing state structure
- Use existing animation names
- Avoid magic numbers
- Use constants for configuration

## Overnight Automation
### Preparation
- Ensure `.agent-todo.md` contains validated tasks
- Confirm planner and reviewer input is complete if needed
- Validate task formatting with available scripts

### Execution
- Run automation from repository root
- Suggested command:
```bash
cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1
./scripts/overnight-agent.sh > logs/manual-start.log 2>&1 &
```
- Process:
  1. Read first incomplete task
  2. Implement targeted changes
  3. Verify syntax and basic behavior
  4. Commit with a clear message
  5. Mark task complete in TODO
  6. Sleep briefly, then continue

### Safety
- Pause if CPU usage exceeds 75%
- Skip or escalate tasks taking too long
- Revert problematic commits if code does not compile
- Log all errors and escalations

## Morning Review
### First steps
- Check the overnight log in `logs/`
- Review recent commits:
  ```bash
git log --oneline -20
```
- Verify the implemented tasks in browser
- Confirm core gameplay behavior still works

### Review checklist
- [ ] No syntax or runtime errors
- [ ] Animations and input behavior remain correct
- [ ] No regressions in related systems
- [ ] Commit messages are clear
- [ ] Completed tasks match `.agent-todo.md`

### Follow-up
- Invoke the reviewer for audit if major work was completed
- Prepare the next set of tasks for the next overnight run
- If issues are found, revert or fix immediately before continuing

## Recommended Commands
### Planner
- `@planner analyze "<feature>"`
- `@planner prioritize "<task list>"`

### Coder
- `@coder implement <task>`
- `@coder debug <error>`
- `@coder test <feature>`
- `@coder review <file>`

### Reviewer
- `@reviewer audit "<feature>"`
- `@reviewer test "<behavior>"`
- `@reviewer performance "<code>"`

### Local repo commands
- `cd /Users/jp/Desktop/Cat/Cat\ Game\ 2.1`
- `./scripts/validate-tasks.sh`
- `./scripts/overnight-agent.sh`
- `tail -f logs/overnight-*.log`
- `git log --oneline -20`

## Emergency Rules
### If a task is unclear
- Stop implementation
- Document the issue
- Clarify requirements manually
- Do not guess intent

### If compilation fails
- Review error messages
- Attempt one quick fix
- If still failing, revert commit:
```bash
git revert HEAD --no-edit
```
- Log the failure and continue

### If a regression is detected
- Revert the change if it breaks core behavior
- Document the regression and root cause
- Re-test after fix

### If CPU usage is too high
- Pause for 5 minutes
- Check active processes
- Resume when safe

### If overnight automation stalls
- Inspect logs
- Restart the script if necessary
- Confirm `.agent-todo.md` still has valid tasks

### If a task exceeds 45 minutes
- Escalate it
- Add a note in `.agent-todo.md` or task comments
- Move on to the next task

## Recommended solution
This plan is intentionally generic and implementation-agnostic. It preserves the existing high-level workflow without relying on a specific local model or toolchain.

Use: Planner for task breakdown, Coder for implementation, Reviewer for audit.

Keep the process:
- plan → validate → implement → review → repeat
- with clear task templates, explicit acceptance criteria, and emergency rollback rules
