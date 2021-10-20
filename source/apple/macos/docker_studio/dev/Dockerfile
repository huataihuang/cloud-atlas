FROM fedora:34
MAINTAINER vincent huatai <vincent@huatai.me>

ENV container docker

RUN --mount=type=bind,target=/sys/fs/cgroup \
    --mount=type=bind,target=/sys/fs/fuse \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/run/lock \
    dnf -y update && dnf -y install systemd && dnf clean all

RUN dnf -y install openssh-server which procps-ng nmap-ncat mlocate net-tools file \
           iputils tmux bzip2 sysstat unzip nfs-utils parted lsof bind-utils

RUN dnf -y install gcc gcc-c++ make flex autoconf automake ncurses-devel zlib-devel git

# Python 3.9 is installed default

RUN dnf -y install java-latest-openjdk

RUN dnf -y install golang

RUN dnf -y install swift-lang

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

# golang env
USER admin
RUN mkdir /home/admin/go
RUN echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc

EXPOSE 22 80 443

ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
CMD [ "log-level=info", "unit=sysinit.target" ]
