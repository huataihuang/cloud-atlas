for i in {0..11};do
    if [ ! -d /data/brick${i} ];then mkdir -p /data/brick${i};fi
    parted -s -a optimal /dev/nvme${i}n1 mklabel gpt
    # 如果随机遇到以下报错，显示磁盘设备busy无法分区，则添加sleep 1避免上一个parted命令还没处理完就发起下一个parted
    # Error: Error informing the kernel about modifications to partition /dev/nvme1n1p1 -- Device or resource busy.  This means Linux won't know about any changes you made to /dev/nvme1n1p1 until you reboot -- so you shouldn't mount it or use it in any way before rebooting.
    # Error: Failed to add partition 1 (Device or resource busy)
    sleep 1
    parted -s -a optimal /dev/nvme${i}n1 mkpart primary xfs 0% 100%
    parted -s -a optimal /dev/nvme${i}n1 name 1 gluster_brick${i}
    sleep 1
    mkfs.xfs -f -i size=512 /dev/nvme${i}n1p1
    # 如果内核版本低于3.16，则只支持 xfs superblock v4
    # mkfs.xfs (xfsprogs 3.2.4 )默认格式化是 superblock v5，需要增加 -m crc=0,finobt=0 来格式化成 xfs superblock v4:
    # mkfs.xfs -f -i size=512 -m crc=0,finobt=0 /dev/nvme${i}n1p1
    fstab_line=`grep "/dev/nvme${i}n1p1" /etc/fstab`
    if [ ! -n "$fstab_line"  ];then echo "/dev/nvme${i}n1p1 /data/brick${i} xfs rw,inode64,noatime,nouuid 1 2" >> /etc/fstab;fi
    mount /data/brick${i}
done
