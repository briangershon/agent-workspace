# Agent Workspace

## Features

- a safe workspace for your AI agent projects
- your AI agent runs in a Docker container isolated from your host machine
- installs Claude Code by default, but you can install any coding agent you want

## Customize

- **Use Claude Code to customize environment and capabilities**. Run Claude Code and it automatically reads `CLAUDE.md` with information on how to customize.

## What you get

- Pre-installed tools for Claude Code to use
- Isolated Docker container - agent cannot access your host system except for your project files
- Bind-mounted `workspace/` folder on your host for project files
- Docker volume for home folder (`/home/agent`) so agent config and auth tokens persist across restarts

## Prerequisites

- Docker
- Docker Compose

## Setup and Running Container

1. Clone this template repository

2. Build and run the container

```bash
docker-compose up --build
```

3. Connect to your container

```bash
./open-terminal.sh
```

4. Inside the container, you can run your agent and other tools

```bash
claude
```

## Optional Tools: Git Diff Tools

Manually install on your host machine where you're performing diffs, or in container.

`git-delta` provides a nice side-by-side diff view and works as a pager. `difftastic` provides a more semantic diff that understands code structure for complex analysis.

```bash
# on OSX run:
brew install git-delta
brew install difftastic
```

### git-delta as default diff pager (recommended)

Add to `~/.gitconfig`:

```ini
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    side-by-side = true
```

### Use difft on demand

```bash
# One-off difft usage
GIT_EXTERNAL_DIFF=difft git diff

# Or add a git alias to ~/.gitconfig
[alias]
    difft = "!f() { GIT_EXTERNAL_DIFF=difft git diff \"$@\"; }; f"
```

Then run `git difft` or `git difft HEAD~1` for semantic diffs when needed.
