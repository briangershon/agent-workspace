FROM node:24-slim

ENV DEBIAN_FRONTEND=noninteractive

# Minimal deps for Claude Code installer only (rarely changes -> good cache anchor)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Create unprivileged user early
RUN useradd -m -s /bin/bash agent

USER agent

# Install Claude Code as agent user (cached unless lines above change)
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN echo 'export PATH="/home/agent/.local/bin:$PATH"' >> /home/agent/.bashrc \
 && echo 'export PATH="/home/agent/.local/bin:$PATH"' >> /home/agent/.bash_profile
ENV PATH="/home/agent/.local/bin:${PATH}"

# Switch back to root for remaining system packages
# Adding packages here does NOT invalidate the Claude Code layer above
USER root

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list \
  && apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    tini \
    vim \
    git \
    gh \
    ripgrep \
    bubblewrap \
    socat \
    jq \
    tzdata \
    ncurses-term \
    locales \
    locales-all \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    shellcheck \
  && rm -rf /var/lib/apt/lists/*

RUN npm i @ast-grep/cli -g

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV COLORTERM=truecolor
ENV TZ=America/Los_Angeles

USER agent

WORKDIR /workspace

CMD ["tini", "--", "/bin/bash"]
