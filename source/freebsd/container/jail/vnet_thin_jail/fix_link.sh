cd /$jail_zfs/templates/$bsd_ver-RELEASE-base/etc/ssl/certs

# 先保存一份原始列表记录
ls -lh > /tmp/fix_link.txt

# 生成unlink命令
ls | sed "s@^@unlink @" > /tmp/unlink.sh

# 生成fix命令
# 这里不能使用绝对路径链接，否则会报错 link: ffdd40f9.0: Cross-device link
# ls -lh | awk '{print $NF, $(NF-2)}' | cut -c 9- | tail -n +2 | sed  "s@^@link @" > /tmp/fix_link.sh
ls -lh | awk '{print $NF, $(NF-2)}' | tail -n +2 | sed 's@^@ln -s ../@' > /tmp/fix_link.sh

# 检查一下 /tmp/fix_link.sh 是否满足要求
# 没有问题在执行以下2条命令

sh /tmp/unlink.sh
sh /tmp/fix_link.sh
