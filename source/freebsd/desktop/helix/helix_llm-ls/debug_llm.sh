#!/bin/sh
# 显式导出路径
export PATH=$PATH:/usr/local/bin:/home/admin/go/bin
# 将 llm-ls 的 stderr 捕获到文件
/usr/local/bin/llm-ls "$@" 2> /tmp/llm-ls.err
