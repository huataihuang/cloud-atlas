# Use Edge Alpine for dev env
FROM alpine:edge

# prepare proxy for GFW, ss run on Host
# ENV for "podman build & run"
# if only for "podman build", change ENV to ARG
#ARG http_proxy=socks5://127.0.0.1:1082
#ARG https_proxy=socks5://127.0.0.1:1082
#ARG HTTP_PROXY=socks5://127.0.0.1:1082
#ARG HTTPS_PROXY=socks5://127.0.0.1:1082

#!!! Don't use ARG or ENV to set proxy globally, in China GFW break github.com and golang.org, so only set proxy for these site, others are direct access

# Go support GOPROXY, In China, please use "https://goproxy.cn" ，else use "https://proxy.golang.org"
ARG GOPROXY=https://goproxy.cn,direct

# if podman run use "--net=host" then proxy point to 127.0.0.1 (same as host), else
# proxy point to host.containers.internal, but need change sing-box(ss client) listen to 0.0.0.0, and DONT forget config iptables/nftables
# HERE setup proxyon/proxyoff alias in container, user can control proxy switch easyly.
RUN echo 'alias proxyon="export http_proxy=socks5://127.0.0.1:1082 https_proxy=socks5://127.0.0.1:1082 HTTP_PROXY=socks5://127.0.0.1:1082 HTTPS_PROXY=socks5://127.0.0.1:1082 GOPROXY=https://goproxy.cn,direct"' > /etc/profile.d/proxy.sh && \
    echo 'alias proxyoff="unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY GOPROXY"' >> /etc/profile.d/proxy.sh && \
    chmod +x /etc/profile.d/proxy.sh

RUN apk update && apk upgrade

# Devops utilities
RUN apk add --no-cache openssh openssl bind-tools tmux git neovim

# install system core tools 
RUN apk add --no-cache \
    tini \
    su-exec \
    bash \
    git \
    curl \
    doas \
    ripgrep \
    fd \
    fzf \
    ca-certificates

# base compile suit(GCC/Make/Headers), LSP and code format provide by Clang
RUN apk add --no-cache \
    build-base \
    musl-dev \
    gdb \
    cmake \
    linux-headers \
    clang \
    clang-extra-tools

# install language develop env
# Go, Python, Ruby, Rust
# Not install nodesjs, because my Macbook Air 11" Late 2010 too old to run
# If need, you can "apk add nodejs npm"
# NOTE: "py3-pysocks" for pip support socks proxy, else will fail if use "ENV http_proxy=socks5://127.0.0.1:1082"
RUN apk add --no-cache \
    go \
    python3 \
    py3-pip \
    py3-pysocks \      
    ruby \
    ruby-dev \
    rust \
    cargo

# Lightweight LSP and Code Analyszer (without Node.js heavy dependence)
# - C/C++: clangd (include in clang-extra-tools)
# - Rust: rust-analyzer
RUN apk add --no-cache rust-analyzer

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
ENV PATH=$GOPATH/bin:$GEM_HOME/bin:$HOME/.cargo/bin:$HOME/venv/dev/bin:/usr/local/go/bin:$PATH

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
RUN mkdir -p $HOME/.cargo/bin && \
    http_proxy=socks5://127.0.0.1:1082 https_proxy=socks5://127.0.0.1:1082 \
    curl -fsSL https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64 -o $HOME/.cargo/bin/marksman && \
    chmod +x $HOME/.cargo/bin/marksman

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
