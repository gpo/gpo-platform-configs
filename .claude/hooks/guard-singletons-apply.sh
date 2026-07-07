#!/bin/bash
# PreToolUse guard for Bash calls: tf/infra/singletons is global production
# with no staging equivalent, so any tofu/terraform apply touching it must be
# explicitly confirmed by the user, even in auto-accept sessions.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if echo "$command" | grep -qE '\b(tofu|terraform)\b.*\bapply\b' \
  && echo "$command" | grep -q 'singletons'; then
  cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": "tf/infra/singletons is live production with no staging tier. Confirm this apply with the user before running it."}}
EOF
fi
exit 0
