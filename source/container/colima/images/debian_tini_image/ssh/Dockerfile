FROM debian:latest

ENV container=docker

# 对于墙内用户需要构建完善的翻墙代理才能顺利执行这个Dockerfile
# 详情参考 https://cloud-atlas.readthedocs.io/zh-cn/latest/docker/colima/colima_socks_proxy.html

RUN apt-get clean
RUN apt-get update -y
RUN apt-get upgrade -y

# Debian仓库内置tini，可以直接安装
RUN apt-get install tini

# Copy tini entrypoint script
COPY entrypoint_ssh_cron_bash /entrypoint.sh
RUN chmod +x /entrypoint.sh

# SSH
RUN apt-get -y install sudo passwd openssh-client openssh-server curl
# Utilities
RUN apt-get -y install cron tmux vim locales net-tools iproute2 dnsutils plocate gnupg2 git tree unzip lsof wget

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

RUN ssh-keygen -A

# run service when container started - sshd
EXPOSE 22:1122

# Run your program under Tini
# CMD ["/your/program", "-and", "-its", "arguments"]
CMD ["/entrypoint.sh"]
