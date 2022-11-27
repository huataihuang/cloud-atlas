FROM alpine:latest
RUN apk update && apk upgrade
RUN apk add --no-cache bash
RUN apk add --no-cache nginx

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
