FROM node:24-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    ca-certificates \
    curl \
    tini \
    vim \
    git \
    ripgrep \
    bubblewrap \
    socat \
    jq \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

# Create unprivileged user
RUN useradd -m -s /bin/bash agent

USER agent

# Install Claude Code as agent user
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/agent/.local/bin:${PATH}"
ENV COLORTERM=truecolor

WORKDIR /workspace

CMD ["tini", "--", "/bin/bash"]
