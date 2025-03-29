FROM fedora:34
MAINTAINER huatai

ENV container docker

RUN dnf -y update && dnf -y install systemd && dnf clean all

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
#CMD ["/usr/bin/init"]
CMD ["/sbin/init"]
