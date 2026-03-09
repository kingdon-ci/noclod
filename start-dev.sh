#!/bin/bash

SESSION_NAME="noclod"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed."
    exit 1
fi

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Tmux session '$SESSION_NAME' already exists."
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 0
fi

echo "Starting tmux session '$SESSION_NAME'..."

tmux new-session -d -s "$SESSION_NAME" -n "services" -c "$PROJECT_ROOT"

# 1. Start LiteLLM first
tmux send-keys -t "$SESSION_NAME:services.0" "cd litellm-deploy && make" C-m

# 2. Wait for it to get an IP
tmux split-window -h -t "$SESSION_NAME:services" -c "$PROJECT_ROOT"
tmux send-keys -t "$SESSION_NAME:services.1" "cd claude-code-proxy && echo 'Waiting for noclod-litellm container IP...' && while ! container ls | grep -q noclod-litellm; do sleep 1; done && sleep 2 && export LITELLM_IP=\$(container ls | grep noclod-litellm | awk '{print \$6}' | cut -d/ -f1 | head -n 1) && echo \"Found LiteLLM at \$LITELLM_IP\" && export PORT=8082 && export ANTHROPIC_API_KEY=\"ignored-ansi-uses-network-auth\" && export OPENAI_API_KEY=\"st-aighie0ZahY6Ic\" && export OPENAI_BASE_URL=\"http://\$LITELLM_IP:4000/v1\" && uv run claude-code-proxy" C-m

echo "Services started in tmux session '$SESSION_NAME'."
echo "------------------------------------------------"
echo "To manage the session:"
echo "  Attach: tmux attach -t $SESSION_NAME"
echo "  Kill:   tmux kill-session -t $SESSION_NAME"
echo ""
echo "To use Claude Code now:"
echo "  source vars && claude"
echo "------------------------------------------------"
