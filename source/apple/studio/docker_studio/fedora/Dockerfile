FROM fedora:34
MAINTAINER http://fedoraproject.org/wiki/Cloud

ENV container docker

RUN dnf -y update && dnf clean all

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]
CMD ["/usr/bin/init"]
