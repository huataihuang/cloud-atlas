FROM fedora:34
MAINTAINER vincent huatai <vincent@huatai.me>

ENV container docker

RUN dnf -y update && dnf clean all

RUN dnf -y install openssh-server \
    which net-tools iputils procps-ng

# iputils: ping arping tracepath ...
# net-tools: arp ifconfig route ...

#RUN systemctl enable sshd

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

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
CMD ["/usr/bin/init"]
