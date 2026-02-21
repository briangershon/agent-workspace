# agent workspace

A safe workspace for your AI agent projects.

Your AI agent runs in a Docker container isolated from your host machine.

Claude Code by default. Customize to install any coding agent you want.

## Setup

1. Clone this template repository

2. Ask Claude Code to help you understand and customize this project. It'll read `CLAUDE.md` automatically. Or if customizing using a different agent, ask it to first read `CLAUDE.md`.

3. Build and run the container

```bash
docker-compose up --build
```

4. Connect to your container

```bash
./open-terminal.sh
```

5. Inside the container, you can run your agent or other code

```bash
claude
```
