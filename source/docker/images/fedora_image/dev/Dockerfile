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

# set china repo: mirros.163.com
RUN cp -R /etc/yum.repos.d /root/yum.repos.d
RUN rm /etc/yum.repos.d/fedora-cisco-openh264.repo
RUN sed -i 's/metalink=/#metalink=/g' /etc/yum.repos.d/*
RUN sed -i 's/#baseurl=/baseurl=/g' /etc/yum.repos.d/*
RUN sed -i 's/download.example\/pub\/fedora\/linux/mirrors.163.com\/fedora/g' /etc/yum.repos.d/*
RUN cp /root/yum.repos.d/fedora-cisco-openh264.repo /etc/yum.repos.d/

RUN dnf clean all
RUN dnf -y update

# Fedora docker image not include systemd,install systemd by initscripts
RUN dnf -y install which sudo passwd openssh-clients openssh-server sssd-client initscripts \
    vim iproute net-tools bind-utils bzip2 tmux sysstat nfs-utils lsof \
    procps tree file mlocate rsync cronie cronie-anacron \
    git gdb openssl-devel \
    nodejs 

RUN systemctl enable sshd

# add account "admin" and give sudo privilege
RUN groupadd -g 505 admin
RUN useradd -g 505 -u 505 -d /home/admin -m admin
RUN usermod -aG wheel admin
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# set TIMEZONE to Shanghai
RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Add ssh public key for login
RUN mkdir -p /home/admin/.ssh
COPY authorized_keys /home/admin/.ssh/authorized_keys
RUN chown -R admin:admin /home/admin/.ssh
RUN chmod 600 /home/admin/.ssh/authorized_keys
RUN chmod 700 /home/admin/.ssh
#RUN mv /var/run/nologin /var/run/nologin.bak

# swith to admin set home
USER admin
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && sh ~/.vim_runtime/install_awesome_vimrc.sh
RUN python3 -m venv ~/venv3 && source venv3/bin/active
RUN pip install sphinx sphinx_rtd_theme sphinxnotes-strike

# switch back
USER root

# run service when container started - sshd
EXPOSE 22:1122

# systemd
# CMD ["/usr/sbin/init"]

ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
CMD [ "log-level=info", "unit=sysinit.target" ]
