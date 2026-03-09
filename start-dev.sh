#!/bin/bash

# Configuration
SESSION_NAME="noclod"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed."
    exit 1
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Tmux session '$SESSION_NAME' already exists."
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 0
fi

echo "Starting tmux session '$SESSION_NAME'..."

# Create new detached session
tmux new-session -d -s "$SESSION_NAME" -n "services" -c "$PROJECT_ROOT"

# Pane 1: Claude Code Proxy
tmux send-keys -t "$SESSION_NAME:services.0" "cd claude-code-proxy && uv run claude-code-proxy" C-m

# Pane 2: LiteLLM
tmux split-window -h -t "$SESSION_NAME:services" -c "$PROJECT_ROOT"
tmux send-keys -t "$SESSION_NAME:services.1" "cd litellm-deploy && make" C-m

# Optional: Add a third pane for logs or monitoring
# tmux split-window -v -t "$SESSION_NAME:services.0" -c "$PROJECT_ROOT"

echo "Services started in tmux session '$SESSION_NAME'."
echo "------------------------------------------------"
echo "To manage the session:"
echo "  Attach: tmux attach -t $SESSION_NAME"
echo "  Kill:   tmux kill-session -t $SESSION_NAME"
echo ""
echo "To use Claude Code now:"
echo "  source vars && claude"
echo "------------------------------------------------"
