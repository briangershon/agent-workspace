FROM node:24.18-slim

# =============================================================
# CUSTOMIZATION POINTS (see CLAUDE.md for full details):
#   FROM        - change base image (e.g. python:3.12-slim)
#   apt-get     - add/remove system packages below
#   ENV TZ      - set your timezone
#   npm install - add global npm tools
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

# Install Claude Code via Anthropic's apt repo (signed, versioned, faster than the install
# script, and consistent with the gh CLI apt install below). Cached unless lines above change.
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
        -o /etc/apt/keyrings/claude-code.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
        > /etc/apt/sources.list.d/claude-code.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends claude-code \
    && rm -rf /var/lib/apt/lists/*

RUN npm i @ast-grep/cli -g
# Add more global npm tools here if needed:
# RUN npm i -g your-tool

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends \
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
    && rm -rf /var/lib/apt/lists/*

# Separate layer for optional packages: editing this list only busts the
# cache here, not for the recommended packages installed above.
RUN apt-get update && apt-get install -y --no-install-recommends \
    # --- Optional defaults: add/remove for your project ---
    tmux \
    jq \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    shellcheck \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV COLORTERM=truecolor
# customize: your timezone
ENV TZ=America/Los_Angeles

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

# Copy entrypoint script that auto-populates agent-home volume on first start
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER agent

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["tini", "--", "/bin/bash"]
