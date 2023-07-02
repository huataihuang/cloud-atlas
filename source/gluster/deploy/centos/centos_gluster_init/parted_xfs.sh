for i in {0..11};do
    if [ ! -d /data/brick${i} ];then mkdir -p /data/brick${i};fi
    parted -s -a optimal /dev/nvme${i}n1 mklabel gpt
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
