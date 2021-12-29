.. _enable_cgrop_v2_ubuntu_20.04:

===================================
在Ubuntu 20.04 LTS激活Cgroup v2
===================================

在 :ref:`bootstrap_kubernetes_ha` 部署过程中，安装 :ref:`container_runtimes` ，有一个有关 cgroup 版本的选项，可以选择 :ref:`cgroup_v2` 或 :ref:`cgroup_v1` 。虽然对于容器运行通常没有感知，但是对于精细话的磁盘IO控制，需要 Cgroup v2支持。目前，很多上游发行版已经开始默认采用 cgroup v2:

- Fedora (since 31)
- Arch Linux (since April 2021)
- openSUSE Tumbleweed (since c. 2021)
- Debian GNU/Linux (since 11)
- Ubuntu (since 21.10)

.. note::

   `Ubuntu 21.10 Systemd To Finally Ship With Cgroup v2 By Default <https://www.phoronix.com/scan.php?page=news_item&px=Ubuntu-21.10-systemd-cgroup>`_ 算是比较迟缓支持cgroup v2，原因是Ubuntu主推的snap系统迟迟没有支持cgroup v2。不过，从Ubuntu 20.10 开始也默认激活cgroup v2。

cgroup v2 for containers  需要内核版本 4.15 或更高，而建议在 5.2 或更高再使用 cgroup v2。我在 :ref:`bootstrap_kubernetes_ha` 部署中采用 Ubuntu Linux 20.04 LTS，实际上内核已经是 5.4 ，满足使用 cgroup v2要求。并且，我在服务器中没有使用snap技术，所以，我为了能够实践更为精细准确的容器磁盘IO控制，启用 cgoup v2。

如何确定系统是否支持 :ref:`cgroup_v2` ，可以执行以下命令::

   grep cgroup /proc/filesystems

如果系统支持cgroup v2，则会看到::

   nodev   cgroup
   nodev   cgroup2

检查 cgroup v2
===================

如果系统存在 ``/sys/fs/cgroup/cgroup.controllers`` ，则表明已经使用了 cgroup v2 ，否则就是使用 cgroup v1。

在没有激活之前，检查::

   ls /sys/fs/cgroup/cgroup.controllers

输出显示::

   ls: cannot access '/sys/fs/cgroup/cgroup.controllers': No such file or directory

激活 cgroup v2
===================

- 修改 ``/etc/default/grub`` 配置在 ``GRUB_CMDLINE_LINUX`` 添加参数::

   systemd.unified_cgroup_hierarchy=1

- 然后执行更新grup::

   sudo update-grub

- 重启系统::

   sudo shutdown -r now

激活CPU, CPUSET 和 I/O 托管
=============================

- 重启后检查::

   cat /sys/fs/cgroup/cgroup.controllers

可以看到系统提供了多个托管控制::

   cpuset cpu io memory pids rdma

- 但是，一个非root用户默认只有 ``memory`` 控制器和 ``pids`` 控制器::

   cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers

显示::

   memory pids

- 要授权其他控制器，如 ``cpu`` ``cpuset`` 和 ``io`` ，执行以下命令::

   sudo mkdir -p /etc/systemd/system/user@.service.d
   cat <<EOF | sudo tee /etc/systemd/system/user@.service.d/delegate.conf
   [Service]
   Delegate=cpu cpuset io memory pids
   EOF

   sudo systemctl daemon-reload

修订 ``systemd`` 配置之后，需要重新登陆或者或者重启主机，建议重启主机。

.. note::

   我暂时没有实践这部分调整

参考
=======

- `Rootless Containers cgroup v2 <https://rootlesscontaine.rs/getting-started/common/cgroup2/>`_
