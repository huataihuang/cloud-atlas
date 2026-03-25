# Use latest Ubuntu
FROM ubuntu:latest

RUN apt update -y && apt upgrade -y

# Devops utilities
RUN apt -y install sudo openssh-client bind9-dnsutils tmux git neovim

# create admin (UID/GID 1000)
ARG USER=admin
ARG GROUP=admin
ARG UID=1000
ARG GID=1000

# Ubuntu images has "ubuntu" account: uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu)
# I change "ubuntu" to "admin" ,maybe you don't need this step
# Ubuntu images has "video" group: gid=44(video)
# I add "render" group: gid=993(render) , for AMD GPU
# and I add admin to group: sudo(27), adm(4), video(44), render(44), admin(1000)

RUN groupmod -n $USER ubuntu
RUN usermod -l $USER -d /home/$USER -m ubuntu

RUN groupadd -g 993 render && \
    usermod  -aG render $USER 

RUN sed -i 's/%sudo	ALL=(ALL:ALL) ALL/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

CMD ["/bin/bash"]
