#!/usr/bin/env bash
set -euo pipefail

readonly ALLOWED_ROOT="/home/lucas/code/luke"
readonly REPO="/home/lucas/code/luke/study"
readonly REMOTE="git@github.com:flingyeyue/luke-study.git"
readonly WEB_REMOTE="https://github.com/flingyeyue/luke-study"
readonly KEY="/home/lucas/.ssh/luke-study-deploy"
readonly SSH_COMMAND="ssh -i ${KEY} -o IdentitiesOnly=yes -o BatchMode=yes"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

enforce_scope() {
  local cwd repo_root remote key_mode
  cwd="$(pwd -P)"
  case "$cwd" in
    "$ALLOWED_ROOT"|"$ALLOWED_ROOT"/*) ;;
    *) fail "current directory is outside ${ALLOWED_ROOT}" ;;
  esac

  [[ -d "$REPO/.git" ]] || fail "study repository is missing"
  repo_root="$(git -C "$REPO" rev-parse --show-toplevel)"
  [[ "$repo_root" == "$REPO" ]] || fail "unexpected repository root: ${repo_root}"

  remote="$(git -C "$REPO" remote get-url origin)"
  [[ "$remote" == "$REMOTE" ]] || fail "unexpected origin: ${remote}"

  [[ -f "$KEY" ]] || fail "deploy key is missing"
  key_mode="$(stat -c '%a' "$KEY")"
  [[ "$key_mode" == "600" ]] || fail "deploy key permissions must be 600"
}

check_repo() {
  enforce_scope
  printf 'repository: %s\n' "$REPO"
  printf 'remote: %s\n' "$REMOTE"
  git -C "$REPO" status --short --branch
  git -C "$REPO" diff --check
  git -C "$REPO" diff --stat
}

commit_changes() {
  local message="$1"
  enforce_scope
  [[ -n "$message" ]] || fail "commit message is required"
  git -C "$REPO" diff --cached --quiet && fail "no staged changes"
  git -C "$REPO" diff --quiet || fail "unstaged changes remain"
  [[ -z "$(git -C "$REPO" ls-files --others --exclude-standard)" ]] || fail "untracked files remain"
  git -C "$REPO" diff --cached --check

  if git -C "$REPO" config user.name >/dev/null && git -C "$REPO" config user.email >/dev/null; then
    git -C "$REPO" commit -m "$message"
  else
    git -C "$REPO" -c user.name=Codex -c user.email=codex@local commit -m "$message"
  fi
}

report_remote_folders() {
  local commit="$1" path folder
  local -A folders=()

  while IFS= read -r -d '' path; do
    if [[ "$path" == */* ]]; then
      folder="${path%/*}/"
    else
      folder="/"
    fi
    folders["$folder"]=1
  done < <(git -C "$REPO" diff-tree --no-commit-id --name-only -r -z "$commit")

  printf 'remote repository: %s\n' "$WEB_REMOTE"
  printf 'remote branch: main\n'
  printf 'commit: %s\n' "$commit"
  printf 'remote folders:\n'
  printf '%s\n' "${!folders[@]}" | LC_ALL=C sort | while IFS= read -r folder; do
    printf -- '- %s\n' "$folder"
  done
}

push_main() {
  local branch local_head remote_head
  enforce_scope
  [[ -z "$(git -C "$REPO" status --porcelain)" ]] || fail "worktree must be clean before push"
  branch="$(git -C "$REPO" branch --show-current)"
  [[ "$branch" == "main" ]] || fail "expected main branch, found ${branch}"

  GIT_SSH_COMMAND="$SSH_COMMAND" git -C "$REPO" push -u origin main
  local_head="$(git -C "$REPO" rev-parse HEAD)"
  remote_head="$(GIT_SSH_COMMAND="$SSH_COMMAND" git -C "$REPO" ls-remote origin refs/heads/main | awk '{print $1}')"
  [[ "$local_head" == "$remote_head" ]] || fail "remote verification failed"
  printf 'verified: %s\n' "$local_head"
  report_remote_folders "$local_head"
}

case "${1:-}" in
  check)
    check_repo
    ;;
  commit)
    [[ $# -eq 2 ]] || fail 'usage: study-git.sh commit "message"'
    commit_changes "$2"
    ;;
  push)
    [[ $# -eq 1 ]] || fail 'usage: study-git.sh push'
    push_main
    ;;
  *)
    fail 'usage: study-git.sh {check|commit "message"|push}'
    ;;
esac
