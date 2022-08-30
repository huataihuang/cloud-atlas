# 使用 DOCKER
# docker build --rm -t local/fedora-systemd .
# docker run -itd --privileged=true -p 1122:22 --hostname fedora --name fedora local:fedora-systemd

# 使用 nerdctl (containerd)
# nerdctl build -t fedora-systemd .
# 交互方式运行
# nerdctl run -it --privileged=true -p 1122:22 --hostname fedora --name fedora fedora-systemd:latest
# 后台运行
# nerdctl run -d --privileged=true -p 1122:22 --hostname fedora --name fedora fedora-systemd:latest

FROM fedora:latest
MAINTAINER vincent huatai <vincent@huatai.me>

ENV container docker

RUN --mount=type=bind,target=/sys/fs/cgroup \
    --mount=type=bind,target=/sys/fs/fuse \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/run/lock

RUN dnf clean all
RUN dnf -y update

# Fedora docker官方镜像默认未包含systemd,通过initscripts安装
RUN dnf -y install which sudo openssh-clients openssh-server initscripts
RUN systemctl enable sshd

# add account "admin" and give sudo privilege
RUN groupadd -g 505 admin
RUN useradd -g 505 -u 505 -d /home/admin -m admin
RUN usermod -aG wheel admin
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# Add ssh public key for login
RUN mkdir -p /home/admin/.ssh
COPY authorized_keys /home/admin/.ssh/authorized_keys
RUN chown -R admin:admin /home/admin/.ssh
RUN chmod 600 /home/admin/.ssh/authorized_keys
RUN chmod 700 /home/admin/.ssh
#RUN mv /var/run/nologin /var/run/nologin.bak

# run service when container started - sshd
EXPOSE 22:1122

# systemd
# CMD ["/usr/sbin/init"]

ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
CMD [ "log-level=info", "unit=sysinit.target" ]
