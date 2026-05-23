FROM debian:latest

ENV container=docker

# 对于墙内用户需要构建完善的翻墙代理才能顺利执行这个Dockerfile
# 详情参考 https://cloud-atlas.readthedocs.io/zh-cn/latest/docker/colima/colima_socks_proxy.html

# 方法一: 强行让 apt-get 走内部专属的 socks5h 隧道，直接无视外界环境变量
#RUN echo 'Acquire::http::Proxy "socks5h://192.168.5.2:1080/";' > /etc/apt/apt.conf.d/proxy.conf && \
#    echo 'Acquire::https::Proxy "socks5h://192.168.5.2:1080/";' >> /etc/apt/apt.conf.d/proxy.conf

# 方法二: 采用开始时CP进容器，结束时rm掉该文件
COPY apt_proxy.conf /etc/apt/apt.conf.d/proxy.conf
#RUN rm /etc/apt/apt.conf.d/proxy.conf

# 方法三: BuildKit 支持 --mount=type=bind ，可以在每一条RUN命令层动态将外部文件映射进容器，但是需要注意每一层(每一个RUN)都是独立无状态的，所以挂载在当前RUN结束时强制卸载
#RUN --mount=type=bind,source=apt_proxy.conf,target=/etc/apt/apt.conf.d/proxy.conf \
#    apt update -y && apt upgrade -y
    

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get clean
RUN apt-get update -y
RUN apt-get upgrade -y

# Debian仓库内置tini，可以直接安装
RUN apt-get -y install tini

# Copy tini entrypoint script
COPY entrypoint_ssh_cron_bash /entrypoint.sh
RUN chmod +x /entrypoint.sh

# SSH
RUN apt-get -y install sudo passwd openssh-client openssh-server curl ca-certificates
# Utilities
RUN apt-get -y install cron tmux vim locales net-tools iproute2 dnsutils plocate gnupg2 git tree unzip lsof wget

# 开发编译依赖
RUN apt-get -y install --no-install-recommends build-essential libssl-dev libyaml-dev zlib1g-dev libgmp-dev libreadline-dev libsqlite3-dev sqlite3 libffi-dev
# neovim依赖
RUN apt-get -y install --no-install-recommends ripgrep fd-find
# 非必须，用于支持我使用的sphinx doc
RUN apt-get -y install graphviz

RUN rm -rf /var/lib/apt/lists/*

# 补全locales
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# add account "admin" and give sudo privilege
# uid & gid follow colima system to access HOME directory
# "docker build --build-arg UID=$(id -u) GID=$(id -g)" will override it.
ARG USER=admin
ARG GROUP=admin
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${GROUP}
RUN useradd -g ${GID} -u ${UID} -m -d /home/${USER} -s /bin/bash ${USER}
RUN adduser ${USER} sudo

RUN echo "%sudo        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# set TIMEZONE to Shanghai
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# RUN mkdir /run/sshd
RUN ssh-keygen -A

USER admin
WORKDIR /home/admin

# 安装 Mise 核心，现代开发语言的万能管理器Mise托管语言栈
RUN curl https://mise.run | sh
RUN echo 'eval "$(~/.local/bin/mise activate)"' >> ~/.bashrc

# 动态将 Mise 垫片和二进制路径暴露给后续构建层和运行时环境
ENV PATH="/home/admin/.local/share/mise/shims:/home/admin/.local/bin:$PATH"

# C/C++ 在安装Cmake时会同时安装
# Rust, Go, Python, Ruby, Rails

# mise 支持命令行传递环境变量实现代理配置
#ARG PROXY_ADDRESS=192.168.5.2:1080
#RUN export all_proxy=socks5h://${PROXY_ADDRESS} && \
#    export http_proxy=http://${PROXY_ADDRESS} && \
#    export https_proxy=http://${PROXY_ADDRESS} && \
#    mise use --global cmake@latest && \
#    mise use --global rust@stable && \
#    mise use --global go@1.23 && \
#    mise use --global python@3.12 && \
#    mise use --global ruby@3.3 && \
#    gem install --no-document rails

# 采用动态挂载
RUN --mount=type=bind,source=mise_proxy.env,target=/home/admin/mise_proxy.env \
    set -a && . /home/admin/mise_proxy.env && set +a && \
    mise use --global cmake@latest && \
    mise use --global rust@stable && \
    mise use --global go@1.26 && \
    mise use --global python@3.14 && \
    mise use --global ruby@3 && \
    mise use --global neovim@stable

# gem不支持socks代理，如果访问阻塞则改为国内源
RUN gem install --no-document rails

# LazyVim
# git 原生参数 -c http.proxy=，临时覆盖全局网络代理
RUN git clone -c http.proxy="socks5h://192.168.5.2:1080" \
    https://github.com/LazyVim/starter /home/admin/.config/nvim && \
    rm -rf /home/admin/.config/nvim/.git
# 通过无头模式（Headless）在构建期将插件和 LSP 彻底刷入镜像中
RUN nvim --headless "+Lazy! sync" +qa

# python program: virtualenv
RUN bash -c 'cd /home/admin && python3 -m venv venv3'
# 我使用Sphinx doc来撰写Cloud-Atlas文档，如不需要请注释
RUN bash -c 'source /home/admin/venv3/bin/activate && pip install sphinx sphinx_rtd_theme sphinxnotes-strike sphinxcontrib-video sphinxcontrib-youtube myst-parser jieba'

# entrypoint.sh 需要使用root身份执行
USER root

# run service when container started - sshd
EXPOSE 22:1122
# next.js nextra
EXPOSE 3000:13000
# Sphinx
EXPOSE 8080:18080
# Jekyll
EXPOSE 4000:14000
# HTTP
EXPOSE 80:1180
# HTTPS
EXPOSE 443:1443

# Run your program under Tini
# CMD ["/your/program", "-and", "-its", "arguments"]
CMD ["/entrypoint.sh"]
