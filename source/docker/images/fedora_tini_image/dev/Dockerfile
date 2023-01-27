# USE DOCKER BUILD
# docker build --rm -t fedora-dev-tini .
# USE DOCKER RUN
# docker run -itd --privileged=true -p 1122:22 --hostname fedora-dev-tini --name fedora-dev-tini fedora-dev-tini

# USE nerdctl (containerd) BUILD
# nerdctl build -t fedora-dev-tini .

# INTERACT RUN
# nerdctl run -it --privileged=true -p 1122:22 --hostname fedora-dev-tini --name fedora-dev-tini fedora-dev-tini:latest

# BACKGROUND RUN
# nerdctl run -d --privileged=true -p 1122:22 --hostname fedora-dev-tini --name fedora-dev-tini fedora-dev-tini:latest

FROM fedora:latest
MAINTAINER vincent huatai <vincent@huatai.me>

ENV container docker

# set china repo: mirros.163.com
RUN cp -R /etc/yum.repos.d /root/yum.repos.d
RUN rm /etc/yum.repos.d/fedora-cisco-openh264.repo
RUN sed -i 's/metalink=/#metalink=/g' /etc/yum.repos.d/*
RUN sed -i 's/#baseurl=/baseurl=/g' /etc/yum.repos.d/*
RUN sed -i 's/download.example\/pub\/fedora\/linux/mirrors.163.com\/fedora/g' /etc/yum.repos.d/*
RUN cp /root/yum.repos.d/fedora-cisco-openh264.repo /etc/yum.repos.d/

RUN dnf clean all
RUN dnf -y update

# Add Tini
ENV TINI_VERSION v0.19.0
# 标准方法是采用ADD方式向镜像添加tini，但是GFW阻碍，改为下载后本地复制
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
COPY tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# Copy tini entrypoint script
COPY entrypoint_ssh_cron_bash /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Fedora docker image not include systemd,install systemd by initscripts
RUN dnf -y install which sudo passwd openssh-clients openssh-server \
    vim iproute net-tools bind-utils bzip2 tmux sysstat nfs-utils lsof \
    procps tree file mlocate rsync cronie cronie-anacron \
    git gdb openssl-devel \
    nodejs 

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

RUN ssh-keygen -A

# run service when container started - sshd
EXPOSE 22:1122

# Run your program under Tini
# CMD ["/your/program", "-and", "-its", "arguments"]
CMD ["/entrypoint.sh"]
