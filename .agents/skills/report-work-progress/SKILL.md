---
name: report-work-progress
description: Report factual project progress at both the start and end of implementation work. Use for coding, testing, documentation, repository maintenance, delivery, or any multi-step task in the Luke workspace where the user expects visibility into the current baseline, planned work, verification, blockers, commits, and remaining tasks.
---

# Report Work Progress

Report progress in the commentary channel before substantive work begins and in the final response after all work for the turn is complete.

## Start Report

Before editing files, running implementation commands, or delegating work, state:

- The current verified baseline or last completed milestone.
- The objective and scope for this work period.
- The next concrete actions.
- Whether user action is currently required.

Keep the report concise and distinguish verified facts from planned work. If repository state must be inspected before the baseline is known, say that inspection is the first action and update the user after inspection.

## Ongoing Updates

Continue normal concise progress updates during longer work. Report material findings, test failures, scope changes, and newly discovered blockers. Do not describe planned work as completed.

Stop and request user action only when the task cannot proceed safely without credentials, authorization, an unavailable external decision, or another action only the user can perform. State the exact action and why it blocks progress.

## End Report

After implementation and verification finish, state:

- The milestone and tasks actually completed.
- The verification commands and measured results.
- The repository, branch, full commit hash, and remote folders when changes were pushed and repository rules require them.
- Remaining work, known limitations, and the next planned milestone.
- Whether user action is required before continuing.

If work failed or remains incomplete, report the last successful point, exact blocker, preserved local state, and the safest next step. Never claim completion based only on code generation or an unverified build.

## Knowledge Base

When the work changes project status, task ownership, decisions, or AI usage evidence, update the Luke study knowledge base according to its repository rules. Use the repository-specific Git Skill for its commit and push workflow.
