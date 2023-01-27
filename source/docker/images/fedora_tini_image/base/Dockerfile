FROM fedora:latest

# set china repo: mirros.163.com
RUN cp -R /etc/yum.repos.d /root/yum.repos.d
RUN rm /etc/yum.repos.d/fedora-cisco-openh264.repo
RUN sed -i 's/metalink=/#metalink=/g' /etc/yum.repos.d/*
RUN sed -i 's/#baseurl=/baseurl=/g' /etc/yum.repos.d/*
RUN sed -i 's/download.example\/pub\/fedora\/linux/mirrors.163.com\/fedora/g' /etc/yum.repos.d/*
RUN cp /root/yum.repos.d/fedora-cisco-openh264.repo /etc/yum.repos.d/

RUN dnf clean all
RUN dnf -y update

ENTRYPOINT ["/usr/bin/bash"]
