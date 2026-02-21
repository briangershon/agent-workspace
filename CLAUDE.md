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
- Add packages your project needs (e.g., python3, ripgrep, gh, awscli)
- Remove packages you don't need to reduce image size

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
- `./home:/home/agent` — persists agent config, skills, auth tokens
- `./workspace:/workspace` — primary project workspace
- Add more mounts to share data from host (e.g., `./data:/data:ro`)

### 7. Networking / Ports

- File: `docker-compose.yml`
- Add `ports:` to expose services (e.g., `"3000:3000"` for a dev server)
- Add sibling services (databases, APIs, mock tools) to the same Compose file

### 8. Additional Services (Recommended for Untrusted Tools)

- Avoid installing untrusted third-party binaries directly in the agent container — they would have access to credentials and the host mount
- Instead, add a sibling service to `docker-compose.yml` that serves the tool via an API, keeping it isolated from the agent container
- See: https://github.com/briangershon/agent-tools-at-arms-length

### 9. Skills

- User-level skills: `home/agent/.claude/skills/`
- Project-level skills: `workspace/.claude/skills/`
- Drop skill files into these directories; they are mounted into the container

### 10. Agent Rules

- File: `workspace/AGENTS.md` (read by all agents) and `workspace/CLAUDE.md` (Claude Code specific)
- Define project-specific rules, constraints, coding standards, or tool preferences here

## Key Files

| File                  | Purpose                                              |
| --------------------- | ---------------------------------------------------- |
| `Dockerfile`          | Container image: base image, packages, agent install |
| `docker-compose.yml`  | Service config: volumes, env vars, ports, networks   |
| `open-terminal.sh`    | Opens a shell in the running container               |
| `home/agent/`         | Persisted agent home dir (skills, auth, config)      |
| `workspace/`          | Persisted project workspace                          |
| `workspace/AGENTS.md` | Agent rules (all agents)                             |
| `workspace/CLAUDE.md` | Claude Code specific rules                           |
