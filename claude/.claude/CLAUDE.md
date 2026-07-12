# Shell environment

- `docker` is aliased to `podman` (no real docker binary is installed). Mostly CLI-compatible but not identical: networking, volume semantics, and rootless defaults differ.
- `nvm` is aliased to `fnm`. Subcommands mostly overlap but not all.
- Other aliases (`ls`/`l`/`ll` -> eza, `cd` -> zoxide) are interactive-only and do not apply to Bash tool commands, but keep them in mind for commands you suggest the user run in their own terminal.

## Other notes

- `KUBE_EDITOR="zed --wait"` — `kubectl edit` opens Zed.
- `DOCKER_HOST` is set to the podman socket, so SAM/docker-compose tools talk to podman.
- `k` = `kubectl`, `kx` = `kubectx`.
- Tool runtimes (node, python, etc.) are managed by `mise` — versions come from `mise`, not the system.

## Investigations & debugging

- Base conclusions on facts and evidence (logs, command output, code you actually read) — not assumptions.
- If you offer a hypothesis, label it explicitly as a hypothesis and distinguish it from what is verified.

## Code standards

- Generated code should be clean and simple (KISS). Apply the /simplify concepts while writing, not just after: prefer the most direct implementation, reuse existing code over adding new, and avoid needless abstractions, layers, or configurability.
- Never use em dashes or other non-ASCII typographic characters (smart quotes, ellipsis, arrows, etc.) in code or comments. Stick to plain ASCII: use "-" instead of an em dash, straight quotes, "...".
