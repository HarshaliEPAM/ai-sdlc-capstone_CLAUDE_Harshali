#!/bin/sh

# Silently consume standard input from Claude Code to prevent I/O blocking
cat > /dev/null

STATE_FILE=".sdlc/workflow-state.json"

# No workflow started yet: allow normal commands (e.g. git inspection/setup)
# so the gate only kicks in once a workflow is actually in progress.
if [ ! -f "$STATE_FILE" ]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "defer"
  }
}
EOF
  exit 0
fi

# List of stages required to be marked as COMPLETED
REQUIRED_STAGES="REQUIREMENT PLANNING DESIGN IMPLEMENTATION TESTING CODE_REVIEW"
PENDING=""

for stage in $REQUIRED_STAGES; do
  # Check if stage: "COMPLETED" matches (case-insensitive, ignoring spacing/formatting)
  if ! grep -i -E -q "\"$stage\"[[:space:]]*:[[:space:]]*\"COMPLETED\"" "$STATE_FILE"; then
    # Extract the current value using sed for clear terminal reporting
    VALUE=$(grep -i -E "\"$stage\"" "$STATE_FILE" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/' | tr 'a-z' 'A-Z')
    if [ -z "$VALUE" ]; then
      VALUE="MISSING"
    fi
    PENDING="${PENDING}\\n- ${stage}: ${VALUE}"
  fi
done

# If there are any non-completed stages, return 'deny' to block Claude
if [ -n "$PENDING" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🛑 SDLC WORKFLOW GATE BLOCKED\\nAll stages must be COMPLETED before proceeding.\\n\\nPending items:${PENDING}\\n\\nPlease complete these stages in .sdlc/workflow-state.json to lift this block."
  }
}
EOF
  exit 0
fi

# If all checks pass, defer to default user permission levels
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "defer"
  }
}
EOF