# USE DOCKER BUILD
# docker build --rm -t fedora-ssh .
# USE DOCKER RUN
# docker run -itd --privileged=true -p 1122:22 --hostname fedora-ssh --name fedora-ssh fedora-ssh

# USE nerdctl (containerd) BUILD
# nerdctl build -t fedora-ssh .

# INTERACT RUN
# nerdctl run -it --privileged=true -p 1122:22 --hostname fedora-ssh --name fedora-ssh fedora-ssh:latest

# BACKGROUND RUN
# nerdctl run -d --privileged=true -p 1122:22 --hostname fedora-ssh --name fedora-ssh fedora-ssh:latest

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

# Fedora docker image not include systemd,install systemd by initscripts
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
