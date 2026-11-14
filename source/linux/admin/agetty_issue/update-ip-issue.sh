#!/bin/bash
# 获取当前首2个可用的非本地 IPv4 地址(一个是有线，一个是无线)
IP_ADDR=$(hostname -I | tr ' ' '\n' | grep -v '^$' | grep -v '^127\.' | head -n 2)

if [ -z "$IP_ADDR" ]; then
    IP_ADDR="Waiting for network..."
fi

# 写入 /etc/issue 模板
cat << EOF > /etc/issue
Ubuntu 26.04 LTS (\\n \\l)

Current Wireless IP: $IP_ADDR

EOF
