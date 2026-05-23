FROM debian:latest

# 强行让 apt-get 走内部专属的 socks5h 隧道，直接无视外界环境变量
RUN echo 'Acquire::http::Proxy "socks5h://192.168.5.2:1080/";' > /etc/apt/apt.conf.d/proxy.conf && \
    echo 'Acquire::https::Proxy "socks5h://192.168.5.2:1080/";' >> /etc/apt/apt.conf.d/proxy.conf

ENV DEBIAN_FRONTEND=noninteractive

# 此时 apt-get 闭眼全速通过
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl ca-certificates git build-essential \
    && rm -rf /var/lib/apt/lists/*

...
