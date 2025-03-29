FROM alpine:latest
RUN apk update && apk upgrade
RUN apk add --no-cache bash
RUN apk add --no-cache nginx

COPY default.conf /etc/nginx/http.d/
RUN mkdir -p /data/html
COPY index.html /data/html/

EXPOSE 80/tcp

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
