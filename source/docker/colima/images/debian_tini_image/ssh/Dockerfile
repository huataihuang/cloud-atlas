FROM debian:latest

ENV container=docker

RUN apt update -y
RUN apt upgrade -y

# Debian仓库内置tini，可以直接安装
RUN apt install tini

# Copy tini entrypoint script
COPY entrypoint_ssh_cron_bash /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Fedora docker image not include systemd,install systemd by initscripts
RUN apt -y install sudo passwd openssh-client openssh-server curl

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# add account "admin" and give sudo privilege
RUN groupadd -g 505 admin
RUN useradd -g 505 -u 505 -d /home/admin admin
RUN adduser admin sudo
RUN echo "%sudo        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# set TIMEZONE to Shanghai
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir /run/sshd
RUN ssh-keygen -A

# run service when container started - sshd
EXPOSE 22:1122

# Run your program under Tini
# CMD ["/your/program", "-and", "-its", "arguments"]
CMD ["/entrypoint.sh"]
