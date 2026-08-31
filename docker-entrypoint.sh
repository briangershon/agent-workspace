#!/bin/bash
set -e

# Enable bash tab-completion (also activates git's own completion script,
# shipped by the git apt package) on first run only
if ! grep -q 'bash-completion/bash_completion' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Added by docker-entrypoint.sh: enable bash-completion (includes git completion)
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
EOF
fi

# Populate agent-home volume with skills on first run only
mkdir -p "$HOME/.claude/skills"
if [ ! -d "$HOME/.claude/skills/skill-creator" ]; then
    skill-copy https://github.com/anthropics/skills/tree/main/skills/skill-creator "$HOME/.claude/skills"
fi

exec "$@"
