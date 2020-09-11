.. _clone_jetson_system:

================
克隆Jetson系统
================

在 :ref:`backup_restore_jetson` 我介绍了如何通过tar工具备份和恢复一个Ubuntu系统(Jetson)，这种方法是比较常规的Linux备份恢复方案。不过，由于需要调整磁盘UUID以及重建GRUB，所以操作比较繁琐且有一定难度。

其实还有一种非常简单粗暴的备份和恢复操作系统的方法：通过 ``dd`` 命令完整克隆系统。这种方法是块设备的 ``bit`` 复制，所以完全不需要了解上层文件系统的结构和内容，只需要保证目标磁盘设备的空间大于源设备就可以实现。



参考
=====

- `Clone SD Card – Jetson Nano and Xavier NX <https://www.jetsonhacks.com/2020/08/08/clone-sd-card-jetson-nano-and-xavier-nx/>`_
