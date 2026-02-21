# agent workspace

A safe workspace for your AI agent projects.

Your AI agent runs in a Docker container isolated from your host machine.

Claude Code by default. Customize to install any coding agent you want.

**See `CLAUDE.md` for full customization options** (coding agent, packages, volumes, networking, skills, and more). Use Claude Code to customize your agent's environment and capabilities.

## What you get

- Isolated Docker container - agent cannot access your host system
- Persistent home volume for agent config and auth tokens across restarts
- Pre-installed tools: git, gh, ripgrep, jq, tmux, curl, vim
- Bind-mounted `workspace/` folder on your host for project files

## Prerequisites

- Docker
- Docker Compose

## Setup

1. Clone this template repository

2. Build and run the container

```bash
docker-compose up --build
```

3. Connect to your container

```bash
./open-terminal.sh
```

4. Inside the container, you can run your agent or other code

```bash
claude
```

> **Warning:** Running `docker compose down -v` will delete the `agent-home` named volume,
> permanently removing your agent auth tokens and config. Your `workspace/` files are
> unaffected (they are bind-mounted to your local filesystem).
