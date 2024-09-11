FROM debian:latest

ENV container=docker

# 容器内代理设置: 物理服务器上通过SSH Tunnel访问墙外HTTP/HTTPS代理，所以IP地址是Docker的NAT网络网关IP
# 如不需要请注释掉
ENV HTTP_PROXY "http://172.17.0.1:3128"
ENV HTTP_PROXY "http://172.17.0.1:3128"
ENV FTP_PROXY "ftp://172.17.0.1:3128"
ENV NO_PROXY "*.baidu.com,192.168.0.0/16,10.0.0.0/8"

RUN apt update -y
RUN apt upgrade -y

# Debian仓库内置tini，可以直接安装
RUN apt install tini

# Copy tini entrypoint script
COPY entrypoint_ssh_cron_bash /entrypoint.sh
RUN chmod +x /entrypoint.sh

# SSH
RUN apt -y install sudo passwd openssh-client openssh-server curl
# Utilities
RUN apt -y install cron tmux vim-tiny locales net-tools dnsutils plocate gnupg2 git tree unzip

# 补全locales
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

# c program
RUN apt -y install glibc-doc manpages-dev libc6-dev gcc build-essential
# 编译neovim需要
RUN apt -y install cmake gettext
# ruby program install rvm
# python program (debian already inatalled python3)
RUN apt -y install python3.11-venv

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# add account "admin" and give sudo privilege
RUN groupadd -g 505 admin
RUN useradd -g 505 -u 505 -s /bin/bash -d /home/admin -m admin
RUN adduser admin sudo
RUN echo "%sudo        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# set TIMEZONE to Shanghai
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir /run/sshd
RUN ssh-keygen -A

USER admin

# ruby program: rvm install ruby in $HOME
RUN gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable
# /bin/sh 不支持source，需要使用 . 
# 每个RUN都是一个容器，所以为了继承环境变量来运行多个命令，将这些命令写成一行RUN
# rvm需要使用BASH，所以最终改成 bash -c 'xxx && yyy && zzz'
RUN bash -c 'source /home/admin/.rvm/scripts/rvm && rvm install 3.3.4 && gem install rails'
# 我使用Jekyll构建个人blog，如不需要请注释掉下面一行
RUN bash -c 'source /home/admin/.bashrc && gem install bundler jekyll'

# python program: virtualenv
RUN bash -c 'cd /home/admin && python3 -m venv venv3'
# 我使用Sphinx doc来撰写Cloud-Atlas文档，如不需要请注释掉下面两行
RUN bash -c 'source /home/admin/venv3/bin/activate && pip install sphinx && pip install sphinx_rtd_theme && pip install sphinxnotes-strike'
RUN bash -c 'source /home/admin/venv3/bin/activate && pip install sphinxcontrib-video && pip install sphinxcontrib-youtube'

# node program: nvm install node
RUN bash -c "cd /home/admin && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash" 
RUN bash -c "source /home/admin/.bashrc && nvm install 22"

# neovim
RUN bash -c 'mkdir /home/admin/src && source /home/admin/.bashrc && cd /home/admin/src && git clone https://github.com/neovim/neovim.git && cd /home/admin/src/neovim && make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim" && make install && echo "export PATH=\"\$HOME/neovim/bin:\$PATH\"" >> /home/admin/.bashrc && echo alias vi=\"\$HOME/neovim/bin/nvim\" >> /home/admin/.bashrc'
RUN bash -c 'cd /home/admin/src && git clone https://github.com/huataihuang/cloud-studio.git && cd /home/admin/src/cloud-studio/config && sh install.sh'
RUN rm -rf /home/admin/src

# entrypoint.sh 需要使用root身份执行
USER root

# run service when container started - sshd
EXPOSE 22:1122
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
