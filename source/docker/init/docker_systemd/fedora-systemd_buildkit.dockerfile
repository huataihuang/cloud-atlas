# syntax = docker/dockerfile:1.3
FROM fedora:34
MAINTAINER huatai

ENV container docker

#RUN dnf -y update && dnf -y install systemd && dnf clean all
#VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]

#CMD ["/sbin/init"]

RUN --mount=type=bind,target=/sys/fs/cgroup \
    --mount=type=bind,target=/sys/fs/fuse \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/run/lock \
    dnf -y update && dnf -y install systemd && dnf clean all

EXPOSE 22 80 443

ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
CMD [ "log-level=info", "unit=sysinit.target" ]
