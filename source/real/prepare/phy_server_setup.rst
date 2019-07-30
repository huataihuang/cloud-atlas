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
