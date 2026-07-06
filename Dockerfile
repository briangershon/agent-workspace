FROM node:24.18-slim AS base

# =============================================================
# CUSTOMIZATION POINTS (see CLAUDE.md for full details):
#   FROM            - change base image (e.g. python:3.12-slim), below
#   apt-get         - add/remove template-level system packages, below
#   ENV TZ          - set your timezone, below
#   "final" stage   - add YOUR project-specific customizations at the
#                     bottom of this file (search for "ADD YOUR
#                     CUSTOMIZATIONS" or the `FROM base AS final` line)
# =============================================================

ENV DEBIAN_FRONTEND=noninteractive

# Deps required by Claude Code itself, plus what its apt repo setup needs
# (rarely changes -> good cache anchor):
#   ca-certificates, curl - needed to fetch the claude-code apt signing key/package
#   bubblewrap            - bash tool sandboxing
#   socat                 - MCP server connections
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    bubblewrap \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Create unprivileged user early
RUN useradd -m -s /bin/bash agent

# Claude Code's own diagnostics expect ~/.local/bin on PATH for its native binary/self-update
# convention, even though the actual binary here comes from the apt package below (owned by root).
RUN mkdir -p /home/agent/.local/bin && chown -R agent:agent /home/agent/.local
ENV PATH="/home/agent/.local/bin:${PATH}"

# Register the Claude Code and GitHub CLI apt repos (signed, versioned, faster than install
# scripts) before a single combined apt-get update+install below. Cached unless lines above change.
# Claude Code channel is "latest", matching Claude Code's own default update messaging.
# To pin to the more conservative channel instead, swap "latest" for "stable" in the deb line below
# (both the path segment and the suite name).
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
    -o /etc/apt/keyrings/claude-code.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/latest latest main" \
    > /etc/apt/sources.list.d/claude-code.list \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list

# Single apt-get update+install for both new repos plus recommended packages, to avoid a
# redundant apt index refresh per repo.
RUN apt-get update && apt-get install -y --no-install-recommends \
    claude-code \
    # --- Recommended: enables specific Claude Code features (git/gh/ripgrep),
    #     plus container/terminal correctness (tini/tzdata/ncurses-term/locales) -
    #     not strictly required, but broadly useful ---
    tini \
    git \
    gh \
    ripgrep \
    tzdata \
    ncurses-term \
    locales \
    locales-all \
    tmux \
    shellcheck \
    jq \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# install npm packages
RUN npm i @ast-grep/cli -g

ARG TARGETARCH

# Install Neovim from the latest upstream prebuilt binary (Debian's apt package lags upstream releases)
RUN NVIM_ARCH=$( [ "$TARGETARCH" = "arm64" ] && echo arm64 || echo x86_64 ) \
    && curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz" \
    | tar -C /opt -xz \
    && mv "/opt/nvim-linux-${NVIM_ARCH}" /opt/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/vim

# Install skill-copy system-wide
RUN LATEST=$(curl -fsSL https://api.github.com/repos/briangershon/skill-copy/releases/latest | jq -r '.tag_name') \
    && VERSION=${LATEST#v} \
    && curl -fsSL "https://github.com/briangershon/skill-copy/releases/download/${LATEST}/skill-copy_${VERSION}_linux_${TARGETARCH}.tar.gz" \
    | tar -C /usr/local/bin -xz skill-copy

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV COLORTERM=truecolor
# customize: your timezone
ENV TZ=America/Los_Angeles

# Copy entrypoint script that auto-populates agent-home volume on first start
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

FROM base AS final

# =============================================================================
# PROJECT CUSTOMIZATIONS - ADD YOUR STUFF BELOW THIS LINE
#
# Everything above (base image, Claude Code, git/gh/ripgrep, tmux/jq/python3,
# neovim, etc.) is the template's own tooling - leave it alone unless you're
# intentionally changing template defaults (see CLAUDE.md).
#
# This stage still runs as root (USER agent is set further down), so apt-get
# and other system-level installs work here without extra USER switches.
# =============================================================================

# Extra system packages for this project:
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     your-package \
#     && rm -rf /var/lib/apt/lists/*

# Extra global npm tools for this project:
# RUN npm i -g your-tool

# Project-specific environment variables (also where you can override
# template defaults like TZ without editing the base stage above):
# ENV TZ=America/New_York
# ENV MY_API_BASE_URL=https://example.com

# Copy project-specific files into the image (rare - most projects just use
# the ./workspace bind mount instead; use this only for files needed at
# build time):
# COPY my-config.json /etc/my-config.json

USER agent

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["tini", "--", "/bin/bash"]
