FROM alpine:latest

ENV container=docker

RUN apk update && apk upgrade

# Alpine Linux 仓库内置tini，可以直接安装
RUN apk add --no-cache tini

# Copy tini entrypoint script
COPY entrypoint_ssh_cron_ash /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Devops utilities
RUN apk add --no-cache openssh sudo bind-tools tmux

# add account "admin" and give sudo privilege
RUN adduser -u 501 -G wheel -h /home/admin -s /bin/sh -D admin
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# set TIMEZONE to Shanghai
RUN apk add --no-cache tzdata
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# init sshd
RUN ssh-keygen -A
# alpine linux sshd default use password auth, empty password will lock account, change to disable password auth
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# developement
RUN apk add build-base
RUN apk add gdb strace
RUN apk add go
RUN apk add rust
# nodejs选择LTS版本
RUN apk add nodejs-lts

# run service when container started - sshd
EXPOSE 22:1122

# Run your program under Tini
# CMD ["/your/program", "-and", "-its", "arguments"]
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
