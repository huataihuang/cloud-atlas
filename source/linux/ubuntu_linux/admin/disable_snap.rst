.. _disable_snap:

============================
在Ubuntu 20.04中禁用Snaps
============================

在 :ref:`snap` 我介绍了Ubuntu的容器方式运行桌面应用的包管理工具 snap ，这确实是一个神奇的工具，构建了安全的应用程序运行环境，且提供了不影响操作系统的无依赖安装应用。不过，在一些情况下可能会需要禁用snap:

- 生产环境大量运行基于 :ref:`docker` 的 :ref:`kubernetes` ，docker容器实现的是和snap相似目标
- 在 :ref:`arm` 架构的 :ref:`raspberry_pi` 硬件资源非常宝贵，我发现当网络启用时， `snapd` 会始终占用一个cpu核心的30%资源::

   top - 06:39:00 up 1 min,  1 user,  load average: 0.85, 0.36, 0.13
   Tasks: 138 total,   1 running, 137 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  5.8 us,  1.8 sy,  0.0 ni, 89.2 id,  3.2 wa,  0.0 hi,  0.1 si,  0.0 st
   MiB Mem :   1848.2 total,   1154.4 free,    199.4 used,    494.5 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   1612.2 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      1651 root      20   0 1072380  34368  13640 S  28.1   1.8   0:08.00 snapd
      2306 ubuntu    20   0   10680   3120   2708 R   0.7   0.2   0:00.09 top
         6 root       0 -20       0      0      0 I   0.3   0.0   0:00.08 kworker/0:0H-mmc_complete

这样即使待机状态 :ref:`check_server_temp` 也看到核心问题达到50度以上(未使用风扇情况下)。所以有必要禁用不使用的snapd。

移除现存Snaps
===============

- 在新安装的Ubuntu中，已经默认安装了部分snaps，可以通过以下命令查看::

   snap list

例如，Raspberry Pi 4的Ubuntu Server 64位版本，输出显示::

   Name    Version   Rev    Tracking       Publisher   Notes
   core18  20200707  1883   latest/stable  canonical✓  base
   lxd     4.0.2     16103  4.0/stable/…   canonical✓  -
   snapd   2.45.2    8543   latest/stable  canonical✓  snapd

.. note::

   - `snap core18 <https://snapcraft.io/core18>`_ 是Ubuntu 18.04 ，提供了在Ubuntu 20.04系统中运行上一个LTS版本应用的能力

并且，如果你执行 ``df -h`` 命令可以看到已经挂载了snap的服务::

   /dev/loop0       49M   49M     0 100% /snap/core18/1883
   /dev/loop1       64M   64M     0 100% /snap/lxd/16103
   /dev/loop2       26M   26M     0 100% /snap/snapd/8543
   /dev/loop3       49M   49M     0 100% /snap/core18/1888

- 使用 ``sudo snap remove <package>`` 命令移除::

   sudo snap remove lxd

但是不能先移除 ``snapd`` ，如果你执行 ``sudo snap remove snapd`` 会提示错误::

   error: cannot remove "snapd": snap "snapd" is not removable: remove all other snaps first

所以先移除 ``core18`` ::

   sudo snap remove core18

最后移除 ``snapd`` ::

   sudo snap remove snapd

.. note::

   此时 ``snapd`` 服务依然在运行，需要卸载 ``snapd`` 软件包来清理

- 检查文件系统挂载 ``df -h`` 可以看到所有snaps相关挂载都已经消除::

   Filesystem      Size  Used Avail Use% Mounted on
   udev            876M     0  876M   0% /dev
   tmpfs           185M  2.7M  183M   2% /run
   /dev/mmcblk0p2  117G  5.0G  108G   5% /
   tmpfs           925M     0  925M   0% /dev/shm
   tmpfs           5.0M     0  5.0M   0% /run/lock
   tmpfs           925M     0  925M   0% /sys/fs/cgroup
   /dev/mmcblk0p1  253M   97M  156M  39% /boot/firmware
   tmpfs           185M     0  185M   0% /run/user/1000

- 删除和清理snapd软件包::

   sudo apt purge snapd

- 执行 ``apt autoremove`` 清理所有无用软件包::

   sudo apt autoremove

- 删除snap目录::

   rm -rf ~/snap
   sudo rm -rf /snap
   sudo rm -rf /var/snap
   sudo rm -rf /var/lib/snapd

现在，所有snaps已经清理干净，我们将使用 :ref:`docker` 构建 :ref:`kubernetes` 。

参考
======

- `Disabling Snaps in Ubuntu 20.04 <https://www.kevin-custer.com/blog/disabling-snaps-in-ubuntu-20-04/>`_
