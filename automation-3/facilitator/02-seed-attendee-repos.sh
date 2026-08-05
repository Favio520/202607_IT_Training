#!/usr/bin/env bash
#
# 02-seed-attendee-repos.sh — push the Azure credentials into GitHub.
#
# Two supported workshop shapes:
#
#   MODE=shared  (default, recommended)
#     One repo, everyone is a collaborator, everyone works on their own branch.
#     The secret + variable are set once on that single repo. Nothing to merge,
#     no per-attendee setup, and each attendee still gets their own workflow run.
#
#   MODE=perrepo
#     Each attendee owns their own repo (e.g. created from your template).
#     Pass the repo list in REPOS or a newline-delimited file via REPOS_FILE.
#     You need admin on each repo for this to work — otherwise have attendees
#     add the secret themselves (that path is in the attendee handout).
#
# Requires: GitHub CLI (gh), authenticated via `gh auth login`.
#
# Usage:
#   MODE=shared REPO=amaxst/gh-azure-workshop ./02-seed-attendee-repos.sh
#   MODE=shared REPO=amaxst/gh-azure-workshop COLLABORATORS="alice bob carol" ./02-seed-attendee-repos.sh
#   MODE=perrepo REPOS="alice/wks bob/wks" ./02-seed-attendee-repos.sh
#
set -euo pipefail

CRED_FILE="${CRED_FILE:-workshop-credentials.txt}"
MODE="${MODE:-shared}"
PERMISSION="${PERMISSION:-push}"   # collaborator permission for MODE=shared

command -v gh >/dev/null 2>&1 || { echo "ERROR: GitHub CLI (gh) not found." >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERROR: not authenticated. Run: gh auth login" >&2; exit 1; }

# ---- Load credentials -------------------------------------------------------
if [[ -n "${AZURE_STORAGE_CONNECTION_STRING:-}" && -n "${AZURE_WEB_ENDPOINT:-}" ]]; then
  CONN="$AZURE_STORAGE_CONNECTION_STRING"
  WEB="$AZURE_WEB_ENDPOINT"
elif [[ -f "$CRED_FILE" ]]; then
  CONN="$(sed -n 's/^Value: *\(DefaultEndpointsProtocol=.*\)$/\1/p' "$CRED_FILE" | head -n1)"
  WEB="$(sed -n 's/^Web endpoint *: *\(.*\)$/\1/p' "$CRED_FILE" | head -n1)"
  WEB="${WEB%/}"
else
  echo "ERROR: no credentials. Run 01-azure-setup.sh first, or export" >&2
  echo "       AZURE_STORAGE_CONNECTION_STRING and AZURE_WEB_ENDPOINT." >&2
  exit 1
fi

[[ -n "$CONN" ]] || { echo "ERROR: could not read the connection string." >&2; exit 1; }
[[ -n "$WEB"  ]] || { echo "ERROR: could not read the web endpoint." >&2; exit 1; }

echo "Web endpoint      : $WEB"
echo "Connection string : ${CONN:0:45}... (${#CONN} chars)"
echo

seed_repo() {
  local repo="$1"
  echo "==> $repo"
  gh secret   set AZURE_STORAGE_CONNECTION_STRING --repo "$repo" --body "$CONN" \
    && echo "    secret   AZURE_STORAGE_CONNECTION_STRING  ok"
  gh variable set AZURE_WEB_ENDPOINT --repo "$repo" --body "$WEB" \
    && echo "    variable AZURE_WEB_ENDPOINT               ok"
}

case "$MODE" in
  shared)
    REPO="${REPO:?set REPO=owner/name for MODE=shared}"
    gh repo view "$REPO" >/dev/null || { echo "ERROR: cannot see $REPO" >&2; exit 1; }
    seed_repo "$REPO"

    if [[ -n "${COLLABORATORS:-}" ]]; then
      echo
      echo "==> Inviting collaborators ($PERMISSION)..."
      for user in $COLLABORATORS; do
        if gh api -X PUT "repos/$REPO/collaborators/$user" \
             -f permission="$PERMISSION" >/dev/null 2>&1; then
          echo "    invited $user"
        else
          echo "    FAILED  $user  (bad username, or you lack admin on $REPO)"
        fi
      done
    fi
    ;;

  perrepo)
    if [[ -n "${REPOS_FILE:-}" ]]; then
      [[ -f "$REPOS_FILE" ]] || { echo "ERROR: $REPOS_FILE not found" >&2; exit 1; }
      mapfile -t REPO_LIST < <(grep -Ev '^\s*(#|$)' "$REPOS_FILE")
    elif [[ -n "${REPOS:-}" ]]; then
      read -r -a REPO_LIST <<< "$REPOS"
    else
      echo "ERROR: set REPOS=\"owner/a owner/b\" or REPOS_FILE=repos.txt" >&2
      exit 1
    fi
    for repo in "${REPO_LIST[@]}"; do
      seed_repo "$repo" || echo "    SKIPPED $repo (no admin access?)"
    done
    ;;

  *)
    echo "ERROR: MODE must be 'shared' or 'perrepo' (got '$MODE')" >&2
    exit 1
    ;;
esac

echo
echo "Done. Attendees can now run the workflow without touching any credentials."
