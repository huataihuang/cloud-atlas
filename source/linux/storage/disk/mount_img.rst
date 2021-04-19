.. _mount_img:

===================
挂载raw镜像(.img)
===================

我在实践 :ref:`install_kali_pi` 遇到了和 :ref:`pi_400_4k_display` 相同的显示黑边问题，需要参考树莓派 ``/boot/config.txt`` 配置进行调整。不过，由于我已经重新通过 ``dd`` 镜像的方式抹除了 :ref:`pi_400` 的树莓派操作系统用来安装 :ref:`kali_linux` 。好在安装Kali之前，我已经通过 :ref:`clone_pi` 方式完整备份了系统镜像，所以还是可以挂载镜像来查看。

.. note::

   在 :ref:`kvm` 虚拟化环境中，我们经常可能需要查看 raw images 中的内容，所以本文方法是一种通用运维技术。

- 在挂载物理设备之前，我们首先需要知道镜像的分区信息::

   sudo fdisk -l pi400.img

``fdisk`` 命令的 ``-l`` 参数可以显示分区，如果需要使用不同的显示单位，还可以使用 ``-u`` 参数制定使用 ``cylinders`` 或 ``sectors`` (默认是sectors)

显示输出::

   Disk pi400.img: 19.65 GiB, 21100823040 bytes, 41212545 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x5b20ba64

   Device     Boot  Start      End  Sectors  Size Id Type
   pi400.img1        8192   532479   524288  256M  c W95 FAT32 (LBA)
   pi400.img2      532480 41212544 40680065 19.4G 83 Linux

这里可以看到有2个分区，第一个分区是从 ``8192`` 扇区到 ``532479`` 扇区，分区类型是 FAT32；第二个分区则是从 ``532480`` 开始到 ``41212544`` ，分区类型是Linux。

- 挂载镜像分区的关键是指定正确的起始扇区，每个扇区是 ``512`` 字节，这里我们可以使用shell进行计算::

   sudo mkdir /mnt/img1
   sudo mount -t vfat -o loop,offset=$((8192 * 512)) pi400.img /mnt/img1

   sudo mkdir /mnt/img2
   sudo mount -t ext4 -o loop,offset=$((532480 * 512)) pi400.img /mnt/img2

第二次挂载会出现一个报错提示::

   mount: /mnt/img2: overlapping loop device exists for /backup/pi400.img.

原因是挂载参数没有指定分区的扇区数量，导致两者覆盖

- 检查所有的 ``loop`` 设备::

   sudo losetup -l

可以看到输出::

   NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE                                DIO LOG-SEC
   /dev/loop1         0      0         1  1 /var/lib/snapd/snaps/core_10958.snap       0     512
   /dev/loop6         0      0         0  0 /backup/pi400.img                          0     512
   /dev/loop4         0      0         1  1 /var/lib/snapd/snaps/anbox_180.snap        0     512
   /dev/loop2         0      0         1  1 /var/lib/snapd/snaps/hello-world_29.snap   0     512
   /dev/loop0         0      0         1  1 /var/lib/snapd/snaps/core_10908.snap       0     512
   /dev/loop5         0      0         0  1 /snap/anbox/180/android.img                0     512
   /dev/loop3         0      0         1  1 /var/lib/snapd/snaps/wechat_2.snap         0     512

- 需要先删除掉 ``loop6`` 设备才能重新挂载::

   sudo losetup -d /dev/loop6

- 通过增加 ``sizelimit`` 参数避免多个分区重叠::

   sudo mount -t vfat -o loop,offset=$((8192 * 512)),sizelimit=$((524288 * 512)) pi400.img /mnt/img1
   sudo mount -t ext4 -o loop,offset=$((532480 * 512)),sizelimit=$((40680065 * 512)) pi400.img /mnt/img2

然后检查挂载::

   df -h

挂载分区如下::

   ...
   /dev/loop6                253M   48M  205M  19% /mnt/img1
   /dev/loop7                 20G   19G   48M 100% /mnt/img2

- 检查loop设备可以看到::

   sudo losetup -l

::

   NAME         SIZELIMIT    OFFSET AUTOCLEAR RO BACK-FILE                                DIO LOG-SEC
   ...
   /dev/loop6   268435456   4194304         1  0 /backup/pi400.img                          0     512
   ...
   /dev/loop7 20828193280 272629760         1  0 /backup/pi400.img                          0     512

参考
======

- `Tutorial: How to mount raw images (.img) images on Linux <https://stefanoprenna.com/blog/2014/09/22/tutorial-how-to-mount-raw-images-img-images-on-linux/>`_
- `How to find the type of an img file and mount it? <https://unix.stackexchange.com/questions/82314/how-to-find-the-type-of-an-img-file-and-mount-it>`_
- `How to mount multiple partitions from disk image simultaneously? <https://unix.stackexchange.com/questions/342463/how-to-mount-multiple-partitions-from-disk-image-simultaneously>`_
- 
