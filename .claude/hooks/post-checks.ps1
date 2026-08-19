#!/bin/sh

# Silently consume standard input from Claude Code to prevent I/O blocking
cat > /dev/null

# 1. Get current git branch name
CURRENT_BRANCH=$(git branch --show-current)

# 2. Safety Guard: Skip PR creation if on a primary branch
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ] || [ "$CURRENT_BRANCH" = "develop" ]; then
  echo "ℹ️ On primary branch ($CURRENT_BRANCH). Skipping automated Pull Request creation."
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
if ! git push -u origin "$CURRENT_BRANCH"; then
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

# 4. Check if GitHub CLI 'gh' is available locally
if ! command -v gh >/dev/null 2>&1; then
  echo "⚠️ GitHub CLI ('gh') is not installed. Skipping automated Pull Request."
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

# 5. Check if a PR already exists for this branch
if gh pr view --json url >/dev/null 2>&1; then
  PR_URL=$(gh pr view --json url -q .url)
  echo "✅ Pull Request already exists: $PR_URL"
else
  # 6. Open a draft PR using '--fill' to pull titles and description from commits
  echo "📦 Creating Draft Pull Request on GitHub..."
  if PR_OUTPUT=$(gh pr create --draft --fill 2>&1); then
    echo "🎉 Draft Pull Request successfully opened!"
    echo "$PR_OUTPUT"
  else
    echo "⚠️ Failed to create GitHub PR. Run 'gh auth status' to verify login permissions."
  fi
fi

# 7. Complete the turn successfully
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "defer"
  }
}
EOF