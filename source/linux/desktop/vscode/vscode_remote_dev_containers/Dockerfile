FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 安装系统基础依赖
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
       curl \
       git \
       build-essential \
       software-properties-common

# 1. 安装指定版本的 Go 
ENV GO_VERSION=1.27.3
RUN curl -L https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -xz -C /usr/local
ENV PATH=$PATH:/usr/local/go/bin

# 2. 安装 Python 及常用工具
RUN apt-get -y install --no-install-recommends \
       python3-pip \
       python3-venv \
       python3-dev

# 3. 安装现代 Python 依赖管理工具 Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

# 设置工作目录
WORKDIR /workspace
