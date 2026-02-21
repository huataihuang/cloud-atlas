# Use latest Ubuntu
FROM ubuntu:latest

RUN apt update && apt upgrade

# Devops utilities
RUN apt install sudo openssh-client bind9-dnsutils tmux git neovim

# create admin (UID/GID 1000)
ARG USER=admin
ARG GROUP=admin
ARG UID=1000
ARG GID=1000

RUN groupadd -g ${GID} ${GROUP} && \
    useradd  -u ${UID} -G ${GROUP} -s /bin/bash -h /home/${USER} ${USER} && \
    groupadd -g 44  video && \
    groupadd -g 993 render && \
    usermod  -aG sudo,adm,video,render admin && \
    echo "%sudo	ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

CMD ["/bin/bash"]
