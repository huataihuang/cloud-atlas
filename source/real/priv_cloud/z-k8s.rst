.. _z-k8s:

============================
部署Kubernetes集群(z-k8s)
============================

启用systemd的cgroup v2
==========================

用于部署 ``z-k8s`` Kubernetes集群的虚拟机都采用了Ubuntu 20.04，不过，默认没有启用 :ref:`cgroup_v2` 。实际上Kubernetes已经支持cgroup v2，可以更好控制资源分配，所以，调整内核参数 :ref:`enable_cgroup_v2_ubuntu_20.04` 。

- 修改 ``/etc/default/grub`` 配置在 ``GRUB_CMDLINE_LINUX`` 添加参数::

   systemd.unified_cgroup_hierarchy=1

- 然后执行更新grup::

   sudo update-grub

- 重启系统::

   sudo shutdown -r now

- 重启后登陆系统检查::

   cat /sys/fs/cgroup/cgroup.controllers

可以看到::

   cpuset cpu io memory pids rdma

表明系统已经激活 :ref:`cgroup_v2`

.. note::

   所有 ``z-k8s`` 集群节点都这样完成修订

安装Docker运行时
==================
