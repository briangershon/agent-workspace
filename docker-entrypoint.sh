#!/bin/bash
set -e

# Populate agent-home volume with skills on first run only
mkdir -p "$HOME/.claude/skills"
if [ ! -d "$HOME/.claude/skills/skill-creator" ]; then
    skill-copy https://github.com/anthropics/skills/tree/main/skills/skill-creator "$HOME/.claude/skills"
fi

exec "$@"
