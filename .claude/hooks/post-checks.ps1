#!/bin/sh

# Silently consume standard input from Claude Code to prevent I/O blocking
cat > /dev/null

# 1. Get current git branch name
CURRENT_BRANCH=$(git branch --show-current)

# 2. Safety Guard: Skip MR creation if on a primary branch
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ] || [ "$CURRENT_BRANCH" = "develop" ]; then
  echo "ℹ️ On primary branch ($CURRENT_BRANCH). Skipping automated Merge Request creation."
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "defer"
  }
}
EOF
  exit 0
fi

echo "🚀 Preparing to push branch: $CURRENT_BRANCH..."

# 3. Push current branch to remote origin
if ! git push -u origin "$CURRENT_BRANCH" 2>/dev/null; then
  echo "❌ Git push failed. Ensure you have remote write permissions."
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "deny",
    "permissionDecisionReason": "PR Blocked: Failed to push current branch to remote origin."
  }
}
EOF
  exit 0
fi

# 4. Read GitHub token from .claude/.env
GITHUB_TOKEN=""
ENV_FILE=".claude/.env"
if [ -f "$ENV_FILE" ]; then
  GITHUB_TOKEN=$(grep -E "^GITHUB_PAT=" "$ENV_FILE" | sed 's/GITHUB_PAT=//' | tr -d ' \r\n')
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "⚠️ No GitHub token found in $ENV_FILE (GITHUB_PAT). Skipping PR creation."
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "defer"
  }
}
EOF
  exit 0
fi

# 5. Derive owner/repo from remote URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
OWNER_REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]([^/]+/[^/]+)(\.git)?$|\1|; s|\.git$||')
GITHUB_API="https://api.github.com/repos/${OWNER_REPO}"
AUTH_HEADER="Authorization: Bearer $GITHUB_TOKEN"

# 6. Check if PR already exists for this branch
OWNER=$(echo "$OWNER_REPO" | cut -d/ -f1)
EXISTING_PR=$(curl -s -H "$AUTH_HEADER" -H "Accept: application/vnd.github+json" -H "User-Agent: claude-code-hook" \
  "${GITHUB_API}/pulls?head=${OWNER}:${CURRENT_BRANCH}&state=open" | \
  grep -o '"html_url":"[^"]*"' | head -1 | sed 's/"html_url":"//; s/"//')

if [ -n "$EXISTING_PR" ]; then
  echo "✅ Pull Request already exists: $EXISTING_PR"
else
  # 7. Resolve default target branch
  TARGET_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
  [ -z "$TARGET_BRANCH" ] && TARGET_BRANCH="main"

  # 8. Use last commit subject as PR title
  PR_TITLE=$(git log -1 --pretty=%s | sed 's/"/\\"/g')

  echo "📦 Creating Pull Request on GitHub..."
  PR_RESPONSE=$(curl -s -X POST \
    -H "$AUTH_HEADER" \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: claude-code-hook" \
    -H "Content-Type: application/json" \
    -d "{\"head\":\"${CURRENT_BRANCH}\",\"base\":\"${TARGET_BRANCH}\",\"title\":\"${PR_TITLE}\"}" \
    "${GITHUB_API}/pulls")

  PR_URL=$(echo "$PR_RESPONSE" | grep -o '"html_url":"[^"]*"' | head -1 | sed 's/"html_url":"//; s/"//')

  if [ -n "$PR_URL" ]; then
    echo "🎉 Pull Request created: $PR_URL"
  else
    echo "⚠️ Failed to create Pull Request."
    echo "$PR_RESPONSE"
  fi
fi

# 9. Complete the turn successfully
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "defer"
  }
}
EOF
