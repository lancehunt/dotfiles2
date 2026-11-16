FROM node:20-alpine

# Install development tools and utilities
RUN apk add --no-cache \
    # Shell and core utilities
    bash \
    bash-completion \
    # Version control
    git \
    git-lfs \
    # Network utilities
    curl \
    wget \
    openssh-client \
    # Text processing and data tools
    jq \
    yq \
    # Build tools
    make \
    gcc \
    g++ \
    musl-dev \
    python3 \
    python3-dev \
    py3-pip \
    # Additional useful tools
    vim \
    nano \
    less \
    findutils \
    coreutils \
    util-linux \
    procps \
    file \
    rsync \
    zip \
    unzip

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user for running Claude
# Check if group/user with id 1000 already exist, if not create them
RUN (getent group 1000 || addgroup -g 1000 claude) && \
    (getent passwd 1000 || adduser -D -u 1000 -G $(getent group 1000 | cut -d: -f1) claude)

# Set environment variables for interactive shell
ENV SHELL=/bin/bash \
    TERM=xterm-256color \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Set working directory
WORKDIR /workspace

# Switch to non-root user (by UID to handle existing users)
USER 1000

# Default command - start interactive session
ENTRYPOINT ["claude"]
CMD []
