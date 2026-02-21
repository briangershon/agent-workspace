FROM node:24-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    bash \
    ca-certificates \
    curl \
    wget \
    build-essential \
    tini \
    vim \
    git \
    bubblewrap \
    socat \
    jq \
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
