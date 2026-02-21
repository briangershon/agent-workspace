# Agent Workspace

This is a Docker-based AI agent workspace template. When a user asks for help customizing this project, guide them through the options below.

## Customization Options

### 1. Project Name

- File: `docker-compose.yml`, `name:` field (currently `agent-workspace`)
- Action: Update to match your project name

### 2. Coding Agent

- File: `Dockerfile`, line with `curl -fsSL https://claude.ai/install.sh | bash`
- Current: Claude Code
- Alternative: Replace the install command for a different agent (e.g., Aider, Codex, etc.)
- Also update `ENV PATH` if the new agent installs to a different location

### 3. System Packages

- File: `Dockerfile`, `apt-get install` block
- Add packages your project needs (e.g., python3, awscli)
- Remove packages you don't need to reduce image size

#### Installed Tools

The following tools are pre-installed because they directly support Claude Code:

| Tool         | Why it helps Claude Code                                                                 |
| ------------ | ---------------------------------------------------------------------------------------- |
| `git`        | Version control - used by Claude Code's built-in git operations (commit, diff, log, etc.) |
| `gh`         | GitHub CLI - used by Claude Code for PR/issue workflows (create PRs, view issues, etc.) |
| `ripgrep`    | Fast file search - Claude Code's Grep tool uses `rg` for significantly faster codebase searches |
| `jq`         | JSON processor - useful for parsing API responses and config files in agent workflows    |
| `tmux`       | Terminal multiplexer - run multiple sessions; useful when agent needs to run a server and interact with it |
| `vim`        | Text editor - fallback editor available in container shell                               |
| `curl`       | HTTP client - used by Claude Code installer and useful in agent scripts                  |
| `bubblewrap` | Sandboxing - Claude Code uses this for its bash tool sandbox (required for safe command execution) |
| `socat`      | Socket relay - Claude Code uses this internally for MCP server connections               |
| `tini`       | Init process - ensures clean signal handling and zombie process reaping in the container |

### 4. Base Docker Image

- File: `Dockerfile`, `FROM node:24-slim`
- Change if your project needs a different runtime (e.g., `python:3.12-slim`, `ubuntu:24.04`)
- Note: If switching away from Node.js, you may need a different way to install Claude Code

### 5. Environment Variables

- File: `Dockerfile` (build-time) or `docker-compose.yml` under `environment:` (runtime)
- Add API keys, config flags, or tool settings
- For secrets, prefer `docker-compose.yml` `env_file:` pointing to a `.env` file (git-ignored)

### 6. Volume Mounts

- File: `docker-compose.yml`, `volumes:` section
- `agent-home:/home/agent` - named Docker volume that persists agent config, auth tokens, and user-level skills
  - Warning: if this Docker volume is deleted (e.g., `docker compose down -v`), all `/home/agent` files are permanently lost
  - This does NOT affect your `/workspace` files, which are bind-mounted to the local filesystem and persist independently
  - Use this volume for home-dir customizations and user-level skills that are not part of the `/workspace` project - handy when you point `/workspace` at different projects but want your personal config and skills to persist across all of them
  - Additionally this keeps sensitive auth tokens and config out of the host filesystem, so you don't need to worry about gitignoring them.
  - A good option is to write a script that installs customizations you want in `/home/agent` (e.g., custom config files, user-level skills) and run that script after building the container to set up your agent environment.
- `./workspace:/workspace` - primary project workspace
- Add more mounts to share data from host (e.g., `./data:/data:ro`)

### 7. Networking / Ports

- File: `docker-compose.yml`
- Add `ports:` to expose services (e.g., `"3000:3000"` for a dev server)
- Add sibling services (databases, APIs, mock tools) to the same Compose file

### 8. Additional Services (Recommended for Untrusted Tools)

- Avoid installing untrusted third-party binaries directly in the agent container - they would have access to credentials and the host mount
- Instead, add a sibling service to `docker-compose.yml` that serves the tool via an API, keeping it isolated from the agent container
- See: https://github.com/briangershon/agent-tools-at-arms-length
- For trusted services such as PostgreSQL it's also simple to add it as a sibling service in `docker-compose.yml` so it runs alongside the agent on a shared Docker network.

### 9. Skills

- User-level skills: `/home/agent/.claude/skills/` inside the container (use `docker cp` or mount a skills directory to copy files in)
- Project-level skills: `workspace/.claude/skills/`
- Drop project-level skill files into the host directory; they are bind-mounted into the container

### 10. Agent Rules

- File: `workspace/AGENTS.md` (read by all agents) and `workspace/CLAUDE.md` (Claude Code specific)
- Define project-specific rules, constraints, coding standards, or tool preferences here

## Key Files

| File                  | Purpose                                                                                                           |
| --------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `Dockerfile`          | Container image: base image, packages, agent install                                                              |
| `docker-compose.yml`  | Service config: volumes, env vars, ports, networks                                                                |
| `open-terminal.sh`    | Opens a shell in the running container                                                                            |
| `agent-home` volume   | Persisted agent home dir (auth, config, user skills) - Docker named volume; deleted with `docker compose down -v` |
| `workspace/`          | Persisted project workspace                                                                                       |
| `workspace/AGENTS.md` | Agent rules (all agents)                                                                                          |
| `workspace/CLAUDE.md` | Claude Code specific rules                                                                                        |

## Writing Style

- Use only ASCII characters in all Markdown files (no em-dashes, curly quotes, or other non-ASCII symbols)
- Use `-` (spaced hyphen) instead of em-dash
