FROM alpine:latest

ENV container=docker

ARG ADMIN_UID=1000
ARG ADMIN_GID=1000

RUN apk update && apk upgrade

# tini process manager
RUN apk add --no-cache tini

# tini entrypoint script: "here documents" / "here scripts"
# Enable BuildKit: Ensure your Docker daemon is configured to use BuildKit, which is typically enabled by default in recent Docker versions. If not, you might need to set the DOCKER_BUILDKIT=1 environment variable when running docker build.
RUN cat << 'EOF' > /entrypoint.sh
#!/usr/bin/env ash
set -e

# Function to gracefully shut down all background processes
function shutdown() {
    echo "Shutting down services..."
    kill ${CRON_PID} ${NGINX_PID} ${SSHD_PID}
    wait ${CRON_PID} ${NGINX_PID} ${SSHD_PID}
    echo "Services stopped."
}

# Trap termination signals to call the shutdown function
trap shutdown SIGTERM SIGINT

# --- Start the services in the background ---

# Start Crond 
# Use the -f flag to run in the foreground (daemon off mode)
/usr/sbin/crond -f &
CRON_PID=$!
echo "Cron started with PID $CRON_PID"

# Start Nginx
# Use the -g "daemon off;" flag to run in the foreground
# nginx -g "daemon off;" &
# NGINX_PID=$!
# echo "Nginx started with PID $NGINX_PID"

# Start SSHD
# Use the -D flag to prevent forking into the background
/usr/sbin/sshd -D -q &
SSHD_PID=$!
echo "SSHD started with PID $SSHD_PID"

# Wait for any process to exit
# If any service fails, 'wait -n' returns its exit status, and 'set -e'
# ensures the script exits, which tells Tini to stop.
wait -n

# If we reach here, one process has exited.
# Call shutdown to terminate the others cleanly before exiting the script.
shutdown
EOF

RUN chmod +x /entrypoint.sh

# Devops utilities
RUN apk add --no-cache openssh sudo bind-tools tmux

# add account "admin" and give sudo privilege
# "admin" uid/gid same as host (alpine linux)
RUN addgroup -g ${ADMIN_GID} admin
RUN adduser -u ${ADMIN_UID} -G admin,wheel -h /home/admin -s /bin/sh -D admin
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# set TIMEZONE to Shanghai
RUN apk add --no-cache tzdata
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# init sshd
RUN ssh-keygen -A
# alpine linux sshd default use password auth, empty password will lock account, change to disable password auth
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
# podman rootless container can't use service port below 1024
RUN echo "Port 1122" >> /etc/ssh/sshd_config

# developement
RUN apk add build-base
RUN apk add gdb strace
RUN apk add go
RUN apk add rust
# nodejs选择LTS版本
RUN apk add nodejs-lts

# run services when container started
# 现在已经不能使用(早期docker版本可以) EXPOSE 22:1122
# 定义输出多个端口使用 EXPOSE 22 80 443 8080 9000
# 定义输出端口范围 EXPOSE 5000-5010
# 定义输出端口范围及协议 EXPOSE 20000-20100/udp

# 对于开发环境可能在容器中使用不同服务端口，所以不定义 EXPOSE 则允许任意端口输出

# Use Tini as the ENTRYPOINT and pass the wrapper script as its argument.
# The `--` separates Tini arguments from the command to be executed.
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

# The CMD is empty because the entrypoint handles everything.
CMD []
