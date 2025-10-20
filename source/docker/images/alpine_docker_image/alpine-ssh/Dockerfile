FROM alpine:latest

ENV container=docker

RUN apk update && apk upgrade

# Alpine Linux 仓库内置tini，可以直接安装
RUN apk add --no-cache tini

# Copy tini entrypoint script



ENTRYPOINT ["/sbin/tini", "--", "/"]
