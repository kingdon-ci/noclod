# GEMINI.md - Project Context: noclod (Claude Code Evaluation)

This project is a research and evaluation environment for **Claude Code**, focusing on using it with OpenAI-compatible API endpoints (such as AWS Bedrock, Groq, or Kimi via a proxy). It provides a proxy server to translate Claude API calls into OpenAI-compatible requests, enabling the use of alternative LLM providers within the Claude Code CLI.

## Project Overview

*   **Core Goal:** Evaluate Claude Code's effectiveness as a code assistant compared to tools like `continue.dev`.
*   **Main Component:** `claude-code-proxy` - A FastAPI-based server that handles the `/v1/messages` endpoint translation.
*   **Infrastructure:** Includes LiteLLM (`litellm-deploy/`) for model routing and comprehensive guides for production-ready MCP (Model Context Protocol) authentication.
*   **Tech Stack:** Python 3.9+, FastAPI, Uvicorn, UV (Python package manager), Bun (for CLI installation), Docker.

## Architecture

*   **`claude-code-proxy/`**: The primary translation layer. Maps Claude models (Haiku, Sonnet, Opus) to specific backend models (e.g., GPT-4o, Bedrock models) via environment variables.
*   **`litellm-deploy/`**: Configurations for LiteLLM, which acts as a universal gateway to various LLM providers.
*   **`docs/`**: Contains architectural decision records (CDDs), deployment guides, and evaluation reports.
*   **`hack/`**: Helper scripts for environment setup (e.g., installing `uv`, `bun`).

## Building and Running

### Prerequisites
*   [UV](https://github.com/astral-sh/uv) installed (use `hack/install-uv.sh`).
*   [Bun](https://bun.sh/) installed (use `hack/install-bun.sh`).
*   [Mocker](https://github.com/us/mocker) (required for LiteLLM on macOS; a frontend for the official Apple container runtime).

### Setup
1.  **Clone Proxy & Install Claude:**
    ```bash
    make claude-code-proxy
    make install-claude
    ```
2.  **Environment Configuration:**
    ```bash
    cp claude-code-proxy.env claude-code-proxy/.env
    # Edit .env with your OPENAI_API_KEY and OPENAI_BASE_URL
    source vars
    ```
3.  **Install Proxy Dependencies:**
    ```bash
    cd claude-code-proxy
    uv sync
    ```

### Simplified Execution (Recommended)
To start both the Claude Code proxy and LiteLLM in a detached tmux session:
```bash
make dev  # or ./start-dev.sh
source vars
claude
```
The services will run in a background tmux session named `noclod`.

### Manual Execution
1.  **Start the Proxy:**
    ```bash
    cd claude-code-proxy
    uv run claude-code-proxy  # Runs on http://0.0.0.0:8082 by default
    ```
2.  **Run Claude Code:**
    ```bash
    # In a new terminal with 'vars' sourced
    claude
    ```

## Development Conventions

*   **Configuration:** Managed via `.env` files and the `vars` script.
    *   `vars` defines `ANTHROPIC_BASE_URL` (pointing to the proxy) and default models (e.g., `ANTHROPIC_DEFAULT_SONNET_MODEL`).
*   **Coding Style:** Python code in `claude-code-proxy` follows `black` and `isort` formatting standards.
*   **Testing:** 
    *   Proxy tests are located in `claude-code-proxy/tests/` and `claude-code-proxy/src/test_claude_to_openai.py`.
    *   Run tests with `uv run pytest`.
*   **Documentation:** Major architectural decisions and reasoning chains are documented in `REASONING.md` and the `docs/` directory.

## Key Files
*   `README.md`: High-level evaluation goals and disclaimer.
*   `claude-code-proxy/src/main.py`: Entry point for the proxy server.
*   `claude-code-proxy/src/core/config.py`: Configuration and environment variable management.
*   `PRODUCTION_MCP_AUTH_GUIDE.md`: Critical guide for hardening MCP server security.
*   `vars`: Shell script to set up the environment for evaluation.
*   `CLAUDE_VS_CONTINUE.md`: Comparison of Claude Code and continue.dev.
