FROM alpine:edge
ENV container=docker

# Now calibre in edge/testing
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && apk upgrade

# Calibre and pdf utils
RUN apk add --no-cache calibre poppler-utils py3-pypdf

# Calibre Init - prepare volume
RUN mkdir -p /calibre/library
RUN mkdir -p /calibre/auth

# Calibre Init Liberty
# RUN calibredb list --library-path /calibre/library

# Calibre create users db
# create:
# calibre-server --userdb /calibre/auth/users.sqlite --manage-users
# run with users auth (daemon)
# /usr/bin/calibre-server --userdb /calibre/auth/users.sqlite --enable-auth --log /dev/stdout --daemonize /calibre/library

# Please use:
# docker run -dt --name alpine-calibre --hostname alpine-calibre \
#     -p 8080:8080 \
#     -v /Users/admin/docs/calibre/library:/calibre/library \
#     -v /Users/admin/docs/calibre/auth:/calibre/auth \
#     alpine-calibre:latest 

RUN echo "/usr/bin/calibre-server --userdb /calibre/auth/users.sqlite --enable-auth /calibre/library" > /calibre/run.sh
RUN chmod +x /calibre/run.sh

# run service when container started - calibre
EXPOSE 8080:8080

VOLUME ["/calibre/library", "/calibre/auth"]
ENTRYPOINT ["/calibre/run.sh"]
