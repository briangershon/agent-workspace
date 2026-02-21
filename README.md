# agent workspace

A safe workspace for your AI agent project.

Run your AI agent environment safely in a Docker container isolated from your host machine.

Installs Claude Code by default, but you can customize it to install any coding agent you want.

## Setup

Clone this template repository.

Ask Claude Code to help you understand and customize this project. It'll read CLAUDE.md automatically.

Or if using a different agent, ask it to first read `CLAUDE.md`.

Build and run the container:

```bash
docker-compose up --build
```

Connect to your container:

> If your editor supports terminals, such as VSCode you may want to use that so everything is in one place

```bash
./open-terminal.sh
```

Inside the container, you can run your agent or other code:

```bash
claude
```
