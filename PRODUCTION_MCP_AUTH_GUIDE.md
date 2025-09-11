# Production‑Ready Authentication for LiteLLM MCP Servers

## Why Move Beyond a Naïve API‑Key Setup?
- **Single‑user scope** – Your current server only knows a handful of static keys. In production you need per‑user or per‑team identity, revocation, rotation, and audit trails.
- **Transport considerations** – stdio is great for development and Claude Code, but production services should expose a network endpoint (HTTP/SSE) behind TLS so traffic can be inspected and rate‑limited.
- **Least‑privilege enforcement** – Different keys should be scoped to the exact resources they need (read‑only vs write) and the server must enforce those scopes on every request.

## Recommended Architecture
1. **FastAPI HTTP server** – Keep the existing FastAPI logic, but expose it via a standard HTTPS endpoint.
2. **OAuth 2.0 / OpenID Connect** – Use an authorization server (e.g., Keycloak, Auth0, or the `mcp‑oauth2‑proxy` you mentioned) to issue short‑lived access tokens.
3. **Proxy layer** – Deploy `mcp‑oauth2‑proxy` in front of your FastAPI service. It validates the token, injects the original API‑key‑scoped permissions, and forwards the request.
4. **Backend token‑to‑key mapping** – Store a mapping of OAuth client IDs / scopes to the internal API keys your MCP server already understands. The proxy can translate the validated token into the appropriate internal key before forwarding.

## Steps to Harden Your Server
### 1. Switch to HTTP(S) Transport
```bash
uvicorn your_app:app --host 0.0.0.0 --port 443 --ssl-keyfile /path/to/key.pem --ssl-certfile /path/to/cert.pem
```
- Enable TLS termination (or terminate at a front‑proxy like Nginx).
- Keep the stdio entry‑point for Claude Code by wrapping the FastAPI app with `litellm.experimental_mcp_client.load_mcp_tools(..., transport="stdio")` for local testing.

### 2. Integrate `mcp‑oauth2‑proxy`
```bash
git clone https://github.com/matheuscscp/mcp-oauth2-proxy.git
cd mcp-oauth2-proxy
pip install -r requirements.txt
python -m mcp_oauth2_proxy \
    --upstream http://localhost:8000 \
    --issuer https://your‑auth‑server.com \
    --audience litellm-mcp \
    --jwks-uri https://your‑auth‑server.com/.well-known/jwks.json
```
- The proxy validates JWTs, extracts the `sub` claim, and can be configured to look up a corresponding internal API key.
- Set environment variable `MCP_PROXY_KEY_MAP` (JSON) that maps `sub` → internal key and allowed scopes.

### 3. Define Scopes & Permissions
```yaml
# config.yaml (LiteLLM side)
servers:
  my_mcp:
    url: https://mcp.mycompany.com
    auth_type: header
    headers:
      x-mcp-{{alias}}-authorization: "Bearer {{token}}"
    allowed_scopes:
      - read:data
      - write:data
```
- In `mcp-oauth2-proxy` configure which scopes map to read vs. write keys.
- Use LiteLLM's `require_approval: "never"` only for fully trusted internal services; otherwise keep the default to require manual approval for high‑risk calls.

### 4. Auditing & Rate Limiting
- **Logging** – Have the proxy emit structured logs (`timestamp`, `user`, `tool`, `action`). Forward them to a SIEM.
- **Rate limits** – Deploy an API gateway (e.g., Kong, Traefik) in front of the proxy to enforce per‑user request caps.
- **Revocation** – Store a revocation list in Redis; the proxy checks it on each request to instantly block compromised tokens.

## Migration Path
| Phase | Goal | Action |
|------|------|--------|
| **Dev** | Keep stdio for Claude Code | Wrap FastAPI with `load_mcp_tools(..., transport="stdio")` |
| **Staging** | Expose HTTPS + proxy | Deploy FastAPI behind TLS, run `mcp‑oauth2‑proxy` with test Auth server |
| **Prod** | Full OAuth2 + audit | Use production IdP, configure scopes, enable logging & rate limiting |

## Common Pitfalls & How to Avoid Them
- **Hard‑coding API keys** – Move them to a secret manager (AWS Secrets Manager, Vault) and let the proxy inject them at runtime.
- **Missing token validation** – Ensure the proxy validates `exp`, `nbf`, and `aud` claims; never trust a token just because it is present.
- **Scope bypass** – Enforce scope checks both in the proxy *and* in the FastAPI handlers; defense‑in‑depth prevents a mis‑configured proxy from granting excess privileges.
- **Plain‑text logs** – Redact tokens and keys before writing logs.

## Quick Checklist Before Going Live
- [ ] TLS termination configured and certificates valid.
- [ ] OAuth2 provider issuing short‑lived JWTs.
- [ ] `mcp‑oauth2‑proxy` mapping table reviewed for correct permissions.
- [ ] Logging pipeline sends masked logs to SIEM.
- [ ] Rate limits applied per user/client.
- [ ] Secrets stored securely, not in repo.
- [ ] End‑to‑end test using Claude Code CLI in stdio mode and the HTTPS endpoint.

---
*This guide assumes familiarity with FastAPI, OAuth 2.0, and LiteLLM MCP configuration. Adjust the specifics to match your organization’s security policies and tooling.*