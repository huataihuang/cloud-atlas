#!/bin/bash

# 读取用户输入
read -p "请输入一个字符串: " str

# 将字符串转换为小写
lower_str=$(echo "$str" | tr '[:upper:]' '[:lower:]')

# 检查是否包含"basic"
if [[ "$lower_str" == *basic* ]]; then
    echo "字符串中包含'basic'"
else
    echo "不包含"
fi
