.. _overlay_mount_influnce_rootfs:

====================================
overlay挂载影响host主机根目录(排查)
====================================

在生产环境中遇到一个非常奇怪的案例，监控系统报告主机有目录100%满了，然而，登陆到服务器上检查 ``df -h`` 却看到所有目录都没有超过 90% :

.. literalinclude:: overlay_mount_influnce_rootfs/df_output
   :caption: ``df -h`` 显示所有目录都没有超过90%，但是告警显示有目录100%
   :emphasize-lines: 6

但是，仔细观察就发现异样: ``/`` 根目录怎么可能只有 ``53M`` 空间

- 使用 :ref:`trace_disk_space_usage` 的方法检查 ``/`` 根目录下哪个目录占用异常:

.. literalinclude:: ../../shell/bash/trace_disk_space_usage/du_current_dir
   :language: bash
   :caption: 只统计当前目录挂载磁盘的使用空间(不跨物理磁盘)

可以看到 ``/var/log`` 实际上已经占用了 ``20G`` :

.. literalinclude:: overlay_mount_influnce_rootfs/du_output
   :caption: 检查磁盘目录占用可以看到占用最多的目录
   :emphasize-lines: 1

- 检查磁盘挂载的 ``/dev/sda3`` 实际大小，也就是通过 :ref:`parted` 输出:

.. literalinclude:: overlay_mount_influnce_rootfs/parted_sda
   :caption: 通过 :ref:`parted` 查看分区容量

输出显示可以看到 ``/dev/sda3`` 分区有 ``55G`` :

.. literalinclude:: overlay_mount_influnce_rootfs/parted_sda_output
   :caption: 通过 :ref:`parted` 查看分区容量输出
   :emphasize-lines: 10

- 通常对于磁盘目录大小显示异常的，应该是多个磁盘被重复挂载到相同目录下导致，所以通过 ``mount`` 命令检查:

.. literalinclude:: overlay_mount_influnce_rootfs/mount_sda3
   :caption: 通过 ``mount`` 检查 ``/dev/sda3`` 挂载

输出如下，显示 :ref:`docker_overlay_driver` 挂载异常:

.. literalinclude:: overlay_mount_influnce_rootfs/mount_sda3_output
   :caption: 通过 ``mount`` 检查 ``/dev/sda3`` 挂载输出
   :emphasize-lines: 2-4

- 通过 :ref:`identify_container_overlay_directory` 可以找出这些异常挂载的 overlay 目录对应的容器:


