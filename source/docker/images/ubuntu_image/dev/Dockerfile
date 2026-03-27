# Use latest Ubuntu
FROM ubuntu:latest

RUN apt update -y && apt upgrade -y

# Devops utilities
RUN apt -y install sudo openssh-client bind9-dnsutils tmux git vim

# create admin (UID/GID 1000)
ARG USER=admin
ARG GROUP=admin
ARG UID=1000
ARG GID=1000

# Ubuntu images has "ubuntu" account: uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu)
# I change "ubuntu" to "admin" ,maybe you don't need this step
# Ubuntu images has "video" group: gid=44(video)
# I add "render" group: gid=993(render) , for AMD GPU
# and I add admin to group: sudo(27), adm(4), video(44), render(44), admin(1000)

RUN groupmod -n $USER ubuntu
RUN usermod -l $USER -d /home/$USER -m ubuntu

RUN groupadd -g 993 render && \
    usermod  -aG render $USER 

RUN sed -i 's/%sudo	ALL=(ALL:ALL) ALL/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

# vim simple config
COPY vimrc /home/$USER/.vimrc 
RUN chown $USER:$GROUP /home/$USER/.vimrc

# helix
COPY maveonair-ubuntu-helix-editor-noble.sources /etc/apt/sources.list.d/
RUN apt update && apt install helix -y

# Go
RUN apt-get install -y golang-go

USER $USER
WORKDIR /home/$USER

# install go tools to $HOME/go/bin
RUN go install golang.org/x/tools/gopls@latest && \
    go install github.com/nametake/golangci-lint-langserver@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest
# if in CHINA, please use:
#     RUN GOPROXY=https://goproxy.cn,direct go install ...
    
# set PATH include $HOME/go/bin
ENV PATH="${HOME}/go/bin:${PATH}"

# install llm-ls
RUN curl -L https://github.com/huggingface/llm-ls/releases/download/0.5.3/llm-ls-x86_64-unknown-linux-gnu.gz | gzip -d -c > /usr/local/bin/llm-ls && chomd +x /usr/local/bin/llm-ls

CMD ["/bin/bash"]
