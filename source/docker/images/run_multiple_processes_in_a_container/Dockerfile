FROM debian:latest

ENV container=docker

RUN apt update -y
RUN apt upgrade -y

# 安装supervisor
RUN apt install -y supervisor

# Copy supervisord.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN apt -y install sudo passwd openssh-client openssh-server curl
RUN apt -y install nginx

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# add account "admin" and give sudo privilege
RUN groupadd -g 501 admin
RUN useradd -g 501 -u 501 -d /home/admin admin
RUN adduser admin sudo
RUN echo "%sudo        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# set TIMEZONE to Shanghai
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir /run/sshd
RUN ssh-keygen -A

# run service when container started - sshd
EXPOSE 22:1122

# Run your program under supervisor
# CMD ["/your/program", "-and", "-its", "arguments"]
CMD ["/usr/bin/supervisord"]
