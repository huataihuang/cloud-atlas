# Use latest Alpine
FROM alpine:latest

RUN apk update && apk upgrade

# Devops utilities
RUN apk add --no-cache openssh openssl bind-tools tmux git neovim

# install system core tools and build-base (C/C++, gdb, compile dependence)
RUN apk add --no-cache \
    tini \
    su-exec \
    bash \
    git \
    curl \
    doas \
    build-base \
    gdb \
    cmake \
    linux-headers

# install language develop env
# Python, Node.js, Go
RUN apk add --no-cache \
    python3 \
    py3-pip \
    nodejs \
    npm \
    go

# install Rust
RUN apk add --no-cache rust cargo

# create admin (UID/GID 1000)
ARG USER=admin
ARG GROUP=admin
ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} ${GROUP} && \
    adduser -u ${UID} -G ${GROUP} -s /bin/bash -D ${USER} && \
    echo "permit nopass :${GROUP}" > /etc/doas.d/doas.conf

# develop enviroment
# Go PATH
ENV GOPATH=/home/${USER}/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
# Rust Cargo bin PATH
ENV PATH=$PATH:/home/${USER}/.cargo/bin

# WorkSpace
WORKDIR /workspace
RUN chown ${USER}:${GROUP} /workspace

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

CMD ["/bin/bash"]
