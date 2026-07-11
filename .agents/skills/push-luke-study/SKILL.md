---
name: push-luke-study
description: Safely inspect, commit, and push updates to the Luke study knowledge base using its repository-specific GitHub Deploy Key. Use only for knowledge-base Git operations when Codex was launched from /home/lucas/code/luke or one of its descendants; refuse use from every other working directory and never use this workflow for another repository.
---

# Push Luke Study

Publish reviewed knowledge-base changes to `flingyeyue/luke-study` with the repository-specific Deploy Key.

## Enforce Scope

1. Run `scripts/study-git.sh check` before any Git mutation.
2. Refuse the operation if the current working directory is not `/home/lucas/code/luke` or a descendant.
3. Operate only on `/home/lucas/code/luke/study`.
4. Refuse to change the expected remote, key path, allowed root, branch, or repository path as part of normal use.
5. Never print, copy, commit, or transmit the private key at `/home/lucas/.ssh/luke-study-deploy`.

## Review and Commit

1. Inspect `git -C /home/lucas/code/luke/study status --short`.
2. Read every changed or untracked knowledge-base file relevant to the task.
3. Check for credentials, private keys, tokens, personal data, generated artifacts, and unrelated changes. Stop and report unsafe or unrelated content.
4. Stage only reviewed paths with `git -C /home/lucas/code/luke/study add -- <paths>`.
5. Inspect `git -C /home/lucas/code/luke/study diff --cached --check` and `git -C /home/lucas/code/luke/study diff --cached --stat`.
6. Run `scripts/study-git.sh commit "<concise commit message>"`. The script refuses unstaged or untracked leftovers so each knowledge-base update remains coherent.

Do not amend, force-push, reset, or rewrite history unless the user explicitly requests that exact operation.

## Push and Verify

1. Run `scripts/study-git.sh push` after a successful commit.
2. Report the full commit hash and whether local `main` matches remote `main`.
3. If authentication or authorization fails, preserve the local commit and report the exact blocker. Never fall back to another user's SSH identity or request secrets in chat.

After changing this skill itself, validate it with the system `quick_validate.py`, commit the knowledge-base update, and push it with this workflow.
