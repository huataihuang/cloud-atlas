.. _ubuntu_server_init:

========================
Ubuntu服务器初始化
========================

在 :ref:`hpe_dl360_gen9` 上部署Ubuntu 20.04.3 LTS Server之后，可以看到有以下特征:

- Ubuntu Server 默认安装了LXC容器，而不是我们常用于Kubernetes的 :ref:`docker` 容器，如果你期望采用最常用的容器技术，需要做一个切换
- Ubuntu默认部署了snapd用于部署沙箱环境运行服务，这可能是你不需要用于底层OS

我的目标是尽可能简化物理服务器上运行的操作系统，而把所有资源都用于 :ref:`kvm` 实现 nested virtualization ，以便部署大规模的云计算虚拟化。所以我在本文实践中，对Ubuntu Server进行精简初始化。

sudo配置
==========

安装过程已经设置了一个可以sudo的账号，为了方便使用，增加免密码设置。例如， ``huatai`` 账号::

   id huatai

可以看到::

   uid=1000(huatai) gid=1000(huatai) groups=1000(huatai),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),116(lxd)

我修订 ``/etc/group`` 将 ``gid`` 20 修订成 ``staff`` ，以及将 huatai 用户修订成 502 ，以便统一不同系统的 uid/gid

- 配置 ``/etc/sudoers`` 添加::

   huatai ALL=(ALL) NOPASSWD:ALL

lxd卸载
===========

Ubuntu默认启用基于LXC的lxd服务，对于我的运行环境实在多余

不过，当尝试 ``apt remove lxc`` 或者 ``apt remove lxd`` 都会提示并没有安装，原来，这些都是通过 :ref:`snap` 部署的，所以通过卸载snap来完成清理

snap卸载
===========

既然在底层os不使用 :ref:`snap` ，所以 :ref:`disable_snap`

- 检查默认安装的snaps::

   snap list

显示输出::

   Name    Version   Rev    Tracking       Publisher   Notes
   core18  20210722  2128   latest/stable  canonical✓  base
   lxd     4.0.7     21029  4.0/stable/…   canonical✓  -
   snapd   2.51.3    12704  latest/stable  canonical✓  snapd

- 使用 ``sudo snap remove <package>`` 命令移除::

   sudo snap remove lxd
   sudo snap remove core18
   sudo snap remove snapd

- 最后删除和清理snapd软件包::

   sudo apt purge snapd

- 执行 ``apt autoremove`` 清理所有无用软件包::

   sudo apt autoremove

- 删除snap目录::

   rm -rf ~/snap
   sudo rm -rf /snap
   sudo rm -rf /var/snap
   sudo rm -rf /var/lib/snapd

参考
======

- `How to install or uninstall lxd on Ubuntu 20.04 LTS (Focal Fossa)? <https://linux-packages.com/ubuntu-focal-fossa/package/lxd>`_
