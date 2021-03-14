.. _clone_pi:

=======================
克隆Raspberry Pi SD卡
=======================

经过一周的磨合，终于调整好 :ref:`pi_400_desktop` 也配置了 :ref:`pi_400_4k_display` ，开始ARM环境的日常开发和运维工作。不过，既然初始化调整很多也很繁琐，如果能做一个快照保存，随时可以恢复系统，就像从树莓派网站下载一个image快速完成安装一样，那该多好。

制作TF卡镜像
==============

- 使用 ``dd`` 命令可以完整制作磁盘镜像，将TF卡通过USB读卡器插到一台Linux主机上使用以下命令进行镜像复制::

   dd bs=100M if=/dev/sdc of=/backup/raspi_studio.img conv=fsync

不过，上述命令虽然可以制作出完整的镜像，但是实际上只能bit-to-bit复制，也是就是说，即使我的树莓派TF卡只使用了128G容量中的5G容量，也要完整复制出一个128G的镜像文件（实际上大多数空间都是空闲的）

收缩镜像
=========

`PiShrink <https://github.com/Drewsif/PiShrink>`_ 是一个bash脚本可以自动收缩树莓派镜像，这样可以制作出较小的镜像文件，可以快速恢复到SD卡::

   Usage: $0 [-adhrspvzZ] imagefile.img [newimagefile.img]
   
     -s         Don't expand filesystem when image is booted the first time
     -v         Be verbose
     -r         Use advanced filesystem repair option if the normal one fails
     -z         Compress image after shrinking with gzip
     -Z         Compress image after shrinking with xz
     -a         Compress image in parallel using multiple cores
     -p         Remove logs, apt archives, dhcp leases and ssh hostkeys
     -d         Write debug messages in a debug log file

通常比较有用的组合是 ``-Z`` 和 ``-a`` ，可以在多核主机上使用 ``xz`` 压缩文件

- 安装 ``pishrink.sh`` ::

   wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
   chmod +x pishrink.sh
   sudo mv pishrink.sh /usr/local/bin

- 收缩镜像文件::

   sudo pishrink.sh /backup/raspi_studio.img

收缩效果显著::

   pishrink.sh: Shrinking image ...
   pishrink.sh: Shrunk /backup/raspi_studio.img from 120G to 6.6G ...

恢复镜像
=========

我主要想通过将TF卡替换成USB 3.0接口上的U盘，来加速存储访问性能。所以通过上述方法制作的镜像，可以通过以下命令 ``dd`` 复制到U盘，然后 :ref:`usb_boot_pi_400` ::

   dd if=raspi_studio.img of=/dev/sdc bs=100M

参考
=======

- `How to clone your Raspberry PI SD card in Linux <https://www.pragmaticlinux.com/2020/12/how-to-clone-your-raspberry-pi-sd-card-in-linux/>`_
