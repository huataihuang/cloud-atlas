.. _run_centos_in_chroot_under_ubuntu:

=====================================
在Ubuntu中构建chroot环境运行CentOS
=====================================

我在 :ref:`dl360_bios_upgrade` 时发现，在企业级Linux市场，果然 :ref:`redhat_linux` 占据了主导地位: HP官方网站只提供Windows安装包和RPM安装包。但这也带来了一点困扰:

- 虽然可以通过 :ref:`alien` 将RPM包转换成DEB包，但是我发现一个非常尴尬的事情: HP官网提供了大量的软件包，但是没有明确软件包如何对应于硬件，而服务器硬件组合实在太繁多，很难确定我现有的 :ref:`hpe_dl360_gen9` 硬件配置是否需要安装更新包
- 同一个软件包可以能包含了针对多种硬件的firmware更新，但列出的型号很难确定和 ``dmidecode`` 或 ``lspci`` 对应

不过，HP为方便系统升级，提供了完整的 SSP 安装光盘，可以通过集成更新脚本自动匹配硬件进行升级更新，这对运维工作带来极大方便。可惜，由于是集成RPM包，所以也不太可能将数百给RPM包转换成DEB包进行一一测试安装。

比较笨的方法是使用基于RHEL/CentOS的U盘运行系统，然后运行SSP安装光盘进行服务器硬件的firmware/BIOS更新。但是，我希望使用更为优雅的方式: 

既然在安装 :ref:`arch_linux` 时能够通过 ``chroot`` 切换系统运行根目录，能够迅速从一种Linux操作系统切换到另一种，那么也可以在这种方式，把我现在在 :ref:`hpe_dl360_gen9` 上安装的 :ref:`ubuntu_linux` 系统切换成 CentOS ，也就能够运行更新软件了。这种方式除了内核不是CentOS发行版内核，其他软件包运行环境并没有区别。

.. note::

   说到 ``chroot`` ，你肯定就想起了 :ref:`docker` : 是的，Docker的底层关键技术就是 ``chroot`` ，也就是能够在一个底层操作系统上切换到不同Linux系统运行的关键。不过，Docker容器环境对容器做了诸多安全限制，并不适合我们这种需要对底层物理服务器更新firmware/bios的场景。

使用 ``rinse`` 初始化 booststap
======================================

Debian提供了 ``rinse`` 脚本来创建很多基于RPM系统的最小化安装::

   sudo apt install rinse

- 初始化系统::

   sudo su -
   rinse --arch amd64 --distribution centos-7 \
       --directory /srv/chroot/centos-7 \
       --mirror http://mirrors.163.com/centos/7.9.2009/os/x86_64/Packages

此时会在 ``/srv/chroot/centos-7`` 目录下下载需要的rpm

我这里遇到报错::

  Extracting: filesystem-3.2-25.el7.x86_64.rpm
  failed to extract filesystem-3.2-25.el7.x86_64.rpm: 16384 at /usr/sbin/rinse line 1254.

检查 ``/usr/sbin/rinse`` 可以看到这步是执行::

   rpm2cpio filesystem-3.2-25.el7.x86_64.rpm | (cd /var/lib/docker/chroot/centos-7 ; cpio --extract --extract-over-symlinks --make-directories --no-absolute-filenames --preserve-modification-time)

模拟执行了一次发现报错是::

   cpio: unrecognized option '--extract-over-symlinks'
   Try 'cpio --help' or 'cpio --usage' for more information.
   
看来 ``cpio`` 参数不兼容，所以修订 ``/usr/sbin/rinse`` 去掉 ``--extract-over-symlinks`` 参数::

   #  Run the unpacking command.
   #
   my $cmd =
   #  "rpm2cpio $file | (cd $CONFIG{'directory'} ; cpio --extract --extract-over-symlinks --make-directories --no-absolute-filenames --preserve-modification-time) 2>/dev/null >/dev/null";
     "rpm2cpio $file | (cd $CONFIG{'directory'} ; cpio --extract --make-directories --no-absolute-filenames --preserve-modification-time) 2>/dev/null >/dev/null";
  
再次运行则完成初始化，此时在 ``/srv/chroot/centos-7`` 目录下就是完成的操作系统::

   total 16K
   lrwxrwxrwx 1 root root    7 Jun 24 10:42 bin -> usr/bin
   dr-xr-xr-x 1 root root    0 Apr 11  2018 boot
   drwxr-xr-x 1 root root   42 Jun 24 10:42 dev
   drwxr-xr-x 1 root root 1.9K Jun 24 10:42 etc
   drwxr-xr-x 1 root root    0 Apr 11  2018 home
   lrwxrwxrwx 1 root root    7 Jun 24 10:42 lib -> usr/lib
   lrwxrwxrwx 1 root root    9 Jun 24 10:42 lib64 -> usr/lib64
   drwxr-xr-x 1 root root    0 Apr 11  2018 media
   drwxr-xr-x 1 root root    0 Apr 11  2018 mnt
   drwxr-xr-x 1 root root    0 Apr 11  2018 opt
   dr-xr-xr-x 1 root root    0 Apr 11  2018 proc
   dr-xr-x--- 1 root root    0 Apr 11  2018 root
   drwxr-xr-x 1 root root   72 Jun 24 10:42 run
   lrwxrwxrwx 1 root root    8 Jun 24 10:42 sbin -> usr/sbin
   drwxr-xr-x 1 root root    0 Apr 11  2018 srv
   dr-xr-xr-x 1 root root    0 Apr 11  2018 sys
   drwxrwxrwt 1 root root    0 Jun 24 10:42 tmp
   drwxr-xr-x 1 root root  106 Jun 24 10:42 usr
   drwxr-xr-x 1 root root  160 Jun 24 10:42 var

创建最小化 ``/dev`` 项目
=========================

CentOS 7已经不再提供 ``MAKEDEV`` 脚本，所以需要在 ``chroot`` 内部执行以下命令创建需要的设备::

   mknod /dev/null c 1 3
   chmod 666 /dev/null
   mknod /dev/ptmx c 5 2
   chmod 666 /dev/ptmx
   mkdir /dev/pts

在物理主机和chroot之间共享用户
===============================

可以方便地在主机系统和chroot中重用相同用户。对于单一用户，非常方便在 ``chroot`` 目录下创建系统用户::

   chroot /srv/chroot/centos-7 adduser --no-create-home \
     --uid $USER_ID $USER_NAME

举例，我的个人系统只有 ``/home/huatai`` ，则执行::

   chroot /srv/chroot/centos-7 adduser --no-create-home \
     --uid 502 huatai

后面我们会用 bind mount 方式将物理主机目录映射到chroot中

(参考)挂载chroot文件系统
==========================

简单来说，至少要挂载 ``/proc`` 伪文件系统，很多工具还需要创建伪终端才能工作。通常执行以下命令::

   mount -t proc proc /srv/chroot/centos-7/proc
   mount -t devpts devpts /srv/chroot/centos-7/dev/pts
   mount -o bind /home /srv/chroot/centos-7/home

不过，我的实践发现有些目录已经创建或者缺失，我实际执行命令如下::

   mount -t proc proc /srv/chroot/centos-7/proc

   mknod /srv/chroot/centos-7/dev/ptmx c 5 2
   chmod 666 /srv/chroot/centos-7/dev/ptmx
   mkdir /srv/chroot/centos-7/dev/pts

   mount -t devpts devpts /srv/chroot/centos-7/dev/pts
   
   mount -o bind /home /srv/chroot/centos-7/home

改进的实际挂载chroot文件系统
==================================

我感觉上述步骤太繁琐，所以参考gentoo linux的安装手册完成上述步骤::

    chroot_dir=/srv/chroot/centos-7
    mount -t proc proc ${chroot_dir}/proc
    mount --rbind /sys ${chroot_dir}/sys
    mount --make-rslave ${chroot_dir}/sys
    mount --rbind /dev ${chroot_dir}/dev
    mount --make-rslave ${chroot_dir}/dev

    mount -o bind /home ${chroot_dir}/home

.. note::

   后来发现 :ref:`dl360_bios_upgrade` 还需要用户账号登陆，所以再添加以下bind，将操作系统的账号密码也映射到chroot环境::

      mount -o bind /etc/passwd ${chroot_dir}/etc/passwd
      mount -o bind /etc/shadow ${chroot_dir}/etc/shadow
      mount -o bind /etc/group ${chroot_dir}/etc/group

   当添加了上述 ``passwd`` 等文件后， :ref:`dl360_bios_upgrade` 过程中通过WEB浏览器访问 Smart Update Manager 管理界面就能够正常使用系统 ``root`` 账号登陆

进入chroot::

    chroot ${chroot_dir} /bin/bash
    source /etc/profile
    export PS1="(chroot) $PS1"

此时已经chroot进入了CentOS系统，可以使用 ``df -h`` 查看系统::

   (chroot) bash-4.2# cat /etc/redhat-release
   CentOS Linux release 7.9.2009 (Core)

   (chroot) bash-4.2# df -h
   Filesystem      Size  Used Avail Use% Mounted on
   /dev/sda2        32G   26G  4.5G  85% /home
   tmpfs            95G     0   95G   0% /sys/fs/cgroup
   udev             95G     0   95G   0% /dev
   tmpfs            95G   12K   95G   1% /dev/shm

验证(通过升级系统)
==========================

- 在chroot的CentOS系统中执行一次升级就可以验证::

   yum update

可以验证这是一个完整的可工作的CentOS 7系统。

现在就可以在这个基础上完成 :ref:`dl360_bios_upgrade` ，即通过HP官方提供的 SPP 光盘，一条脚本命令进行升级

参考
======

- `Installing CentOS in a chroot under Debian <https://www.tt-solutions.com/en/articles/install_centos_in_debian_chroot>`_
