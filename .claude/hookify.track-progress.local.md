---
name: track-progress-reminder
enabled: true
event: stop
action: warn
conditions:
  - field: transcript
    operator: contains
    pattern: implement|create|build|fix|add|update|refactor
  - field: transcript
    operator: not_contains
    pattern: TodoWrite|todo list
---

**Progress tracking reminder**

Substantial work was done but progress wasn't tracked.

**Use TodoWrite to:**
- Break complex tasks into steps
- Track completion status
- Give user visibility into progress
- Ensure nothing is forgotten

**Before stopping, consider:**
1. Were all planned tasks completed?
2. Are there follow-up items to track?
3. Should incomplete work be documented?

**Quick check:**
- If task was multi-step, TodoWrite should have been used
- If task was trivial (< 3 steps), tracking is optional
