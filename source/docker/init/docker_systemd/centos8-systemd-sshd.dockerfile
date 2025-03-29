# Build centos 8 image with ssh:
# ------------------------------
# docker build -f centos8-systemd-sshd -t local:centos8-systemd-sshd .

# create container with systemd
# -------------------------------
# docker run -itd -p 1122:22 --hostname myserver --name myserver \
#   --entrypoint=/usr/lib/systemd/systemd \
#   --env container=docker \
#   --mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup \
#   --mount type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse \
#   --mount type=tmpfs,destination=/tmp \
#   --mount type=tmpfs,destination=/run \
#   --mount type=tmpfs,destination=/run/lock \
#     local:centos8-systemd-sshd --log-level=info --unit=sysinit.target

FROM docker.io/centos:8
MAINTAINER vincent huatai <vincent@huatai.me>

ENV continer=docker

RUN dnf clean all
RUN dnf -y update

RUN dnf -y install which sudo openssh-clients openssh-server

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
# default unprivileged users are not permitted to log in, so rm /var/run/nologin to let users log in
RUN mv /var/run/nologin /var/run/nologin.bak

# run service when container started - sshd
EXPOSE 22:1122

ENTRYPOINT /usr/lib/systemd/systemd
