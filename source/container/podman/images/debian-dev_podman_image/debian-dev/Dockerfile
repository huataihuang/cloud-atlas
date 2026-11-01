# Use Debian latest
FROM debian:latest

ENV container=docker

ENV LANG="en_US.UTF-8" 
ENV LC_ALL="en_US.UTF-8"

# prepare proxy for GFW, ss run on Host
# ENV for "podman build & run"
# if only for "podman build", change ENV to ARG
#ARG HTTP_PROXY=socks5h://127.0.0.1:1080
#ARG HTTPS_PROXY=socks5h://127.0.0.1:1080
#ARG ALL_PROXY=socks5h://127.0.0.1:1080
#ENV http_proxy=${HTTP_PROXY}
#ENV https_proxy=${HTTPS_PROXY}
#ENV all_proxy=${ALL_PROXY}

#!!! Don't use ARG or ENV to set proxy globally, in China GFW break github.com and golang.org, so only set proxy for these site, others are direct access

ARG DEBIAN_FRONTEND=noninteractive

# Go support GOPROXY, In China, please use "https://goproxy.cn" ，else use "https://proxy.golang.org"
ARG GOPROXY=https://goproxy.cn,direct

# if podman run use "--net=host" then proxy point to 127.0.0.1 (same as host), else
# proxy point to host.containers.internal, but need change sing-box(ss client) listen to 0.0.0.0, and DONT forget config iptables/nftables
# HERE setup proxyon/proxyoff alias in container, user can control proxy switch easyly.
RUN echo 'alias proxyon="export http_proxy=socks5://127.0.0.1:1080 https_proxy=socks5://127.0.0.1:1080 HTTP_PROXY=socks5://127.0.0.1:1080 HTTPS_PROXY=socks5://127.0.0.1:1080 GOPROXY=https://goproxy.cn,direct"' > /etc/profile.d/proxy.sh && \
    echo 'alias proxyoff="unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY GOPROXY"' >> /etc/profile.d/proxy.sh && \
    chmod +x /etc/profile.d/proxy.sh

RUN apt-get clean
RUN apt-get update -y && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Devops utilities
RUN apt-get install -y --no-install-recommends \
    openssh-client openssl bind9-dnsutils tmux git neovim \
    && rm -rf /var/lib/apt/lists/*

# install system core tools 
RUN apt-get install -y --no-install-recommends \
    tini \
    sudo \
    net-tools \
    iproute2 \
    plocate \
    gnupg \
    tree \
    unzip \
    lsof \
    wget \
    git \
    curl \
    ripgrep \
    fd-find \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# base compile suit(GCC/Make/Headers), LSP and code format provide by Clang
RUN apt-get install -y --no-install-recommends \
    build-essential \
    gdb \
    cmake \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
    libgmp-dev \
    libreadline-dev \
    libsqlite3-dev \
    sqlite3 \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# install language develop env
# base develop toolchains (C/C++, gmake, Python, Ruby) by apt
RUN apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    ruby-full \
    && gem install rails \
    && rm -rf /var/lib/apt/lists/*

# node.js, go, rust install from official site

# Node.js
# ==========================================
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Go
# ==========================================
ENV GO_VERSION=1.22.5
RUN wget -q https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Rust
# ==========================================
ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
ENV PATH=$PATH:/opt/cargo/bin

# Lightweight LSP and Code Analyszer (without Node.js heavy dependence)
# - C/C++: clangd (include in clang-extra-tools)
# - Rust: rust-analyzer
RUN apt-get install -y --no-install-recommends \
    rust-analyzer \
    && rm -rf /var/lib/apt/lists/*

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# create admin (UID/GID 1000)
ARG USER=admin
ARG GROUP=admin
ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} ${GROUP} && \
    adduser -u ${UID} -G ${GROUP} -s /bin/bash -D ${USER} && \
    echo "permit nopass :${GROUP}" >> /etc/doas.conf && \
    chmod 0400 /etc/doas.conf && \
    chown root:root /etc/doas.conf

# WorkSpace
WORKDIR /workspace
RUN chown ${USER}:${GROUP} /workspace

USER admin

# develop enviroment
# Go PATH
ENV HOME=/home/${USER}
ENV GOPATH=$HOME/go
ENV GEM_HOME=$HOME/.gem/ruby/3.4.0
ENV PATH=$GOPATH/bin:$GEM_HOME/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/venv/dev/bin:/usr/local/go/bin:$PATH

# - Go: gopls
RUN go install golang.org/x/tools/gopls@latest

# python program: virtualenv
RUN bash -c 'mkdir -p $HOME/venv && cd $HOME/venv && python3 -m venv dev'

# - python-frontmatter: Python batch handle YAML frontmatter properties of Astro Markdown
RUN bash -c 'source $HOME/venv/dev/bin/activate && pip install python-frontmatter'
# - Python: ruff + jedi-language-server
RUN bash -c 'source $HOME/venv/dev/bin/activate && pip install jedi-language-server ruff'
# sphinx doc for My "Cloud-Atlas"
RUN bash -c 'source $HOME/venv/dev/bin/activate && pip install sphinx sphinx_rtd_theme sphinxnotes-strike sphinxcontrib-video sphinxcontrib-youtube myst-parser jieba'

# - Ruby: solargraph
# 设置了GEM_PATH之后，不需要 --user-install 参数
RUN gem install --no-document solargraph

# - asciidoctor: AsciiDoc / Antora Offline Analyzer
RUN gem install --no-document asciidoctor asciidoctor-diagram

# - Markdown / Astro MDX: marksman (Markdown LSP write by Rust)
RUN mkdir -p $HOME/.local/bin && \
    http_proxy=socks5://127.0.0.1:1080 https_proxy=socks5://127.0.0.1:1080 \
    curl -fsSL https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64 -o $HOME/.local/bin/marksman && \
    chmod +x $HOME/.local/bin/marksman

# -----------------------------------------------------------------------------
# 配置 Neovim 开发环境 (单文件 init.lua + 插件离线预热)
# -----------------------------------------------------------------------------
USER admin
WORKDIR /home/${USER}

# 1. 复制独立的 init.lua 到 admin 用户的配置目录
#    (--chown 确保复制进来的文件属主直接就是 admin:admin)
RUN mkdir -p /home/admin/.config/nvim
COPY --chown=admin:admin config/nvim/init.lua /home/admin/.config/nvim/init.lua

# 2. 在构建阶段提前下载并编译所有 Neovim 插件 (实现离线开箱即用)
RUN nvim --headless "+Lazy! sync" +qa

# 3. 恢复默认开发工作目录（关键步骤）
WORKDIR /workspace

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

CMD ["/bin/bash"]
