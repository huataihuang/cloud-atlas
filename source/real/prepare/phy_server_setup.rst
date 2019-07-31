.. _phy_server_setup:

=================
物理服务器设置
=================

服务器IPMI
===========

对于服务器管理，远程带外管理是最基本的设置，为服务器设置 :ref:`ipmitool_tips` 运行环境，可以让我们能够在系统异常时远程诊断、重启系统，并且能够如果连接键盘显示器一样对物理服务器进行操作。

.. note::

   可以在安装完Linux操作系统之后，通过操作系统的 ``ipmitool`` 命令来设置带外管理。

- 如果带外系统已经设置了远程管理账号，则在每个IPMI命令之前加上::

   ipmitool -I lanplus -H <IPMI_IP> -U username -P password <ipmi command>

.. note::

   以下配置命令是假设已经安装好操作系统，登陆到Linux系统中，使用root账号执行命令。如果远程执行，则添加上述远程命令选项。

- 配置IPMI账号和访问IP::

   待续

- 冷重启BMC，避免一些潜在问题::

   ipmitool mc reset cold

操作系统
============

- 私有云物理服务器采用CentOS 7.x操作系统，采用最小化安装，并升级到最新版本::

   sudo yum update
   sudo yum upgrade

.. note::

   在CentOS 8正式推出以后，将升级到8.x系列，以获得更好的软件性能及特性。

- 安装必要软件包::

   yum install nmon which sudo nmap-ncat mlocate net-tools rsyslog file ntp ntpdate \
   wget tar bzip2 screen sysstat unzip nfs-utils parted lsof man bind-utils \
   gcc gcc-c++ make telnet flex autoconf automake ncurses-devel crontabs \
   zlib-devel git vim

- 关闭swap（Kubernetes运行要求节点关闭swap)

- 安装EPEL::

   yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

磁盘分区
============

- 服务器磁盘 ``/dev/sda4`` 构建LVM卷，所以首先通过 ``parted /dev/sda`` 划分分区::

   mkpart primary 54.8GB 567GB
   name 4 store
   set 4 lvm on

- 构建LVM卷::

   pvcreate /dev/sda4
   vgcreate store /dev/sda4
   lvcreate --size 256G -n libvirt store
   mkfs.xfs /dev/store/libvirt

- 停止libvirt，将磁盘卷迁移到LVM卷::

   systemctl stop libvirtd
   systemctl stop virtlogd

此时还会提示有sockect没有停止::

   Warning: Stopping virtlogd.service, but it can still be activated by:
     virtlogd-admin.socket
     virtlogd.socket

停止对应socket::

   systemctl stop virtlogd-admin.socket
   systemctl stop virtlogd.socket

此外还需要停止virtlockd::

   systemctl stop virtlockd
   systemctl stop virtlockd.socket

- 此时确保 ``lsof | grep libvirt`` 没有输出之后，才可以迁移 ``/var/lib/libvirt`` 内容::

   mv /var/lib/libvirt /var/lib/libvirt.bak
   mkdir /var/lib/libvirt

   mount /dev/store/libvirt /var/lib/libvirt

   (cd /var/lib/libvirt.bak && tar cf - .)|(cd /var/lib/libvirt && tar xf -)

- 恢复libvirt::

   systemctl start libvirtd
   
