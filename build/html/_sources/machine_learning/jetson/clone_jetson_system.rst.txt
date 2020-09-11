.. _clone_jetson_system:

================
克隆Jetson系统
================

在 :ref:`backup_restore_jetson` 我介绍了如何通过tar工具备份和恢复一个Ubuntu系统(Jetson)，这种方法是比较常规的Linux备份恢复方案。不过，由于需要调整磁盘UUID以及重建GRUB，所以操作比较繁琐且有一定难度。

其实还有一种非常简单粗暴的备份和恢复操作系统的方法：通过 ``dd`` 命令完整克隆系统。这种方法是块设备的 ``bit`` 复制，所以完全不需要了解上层文件系统的结构和内容，只需要保证目标磁盘设备的空间大于源设备就可以实现。

备份和恢复TF卡
==============

clone的目标存储卡容量必须大于源存储卡容量，否则会导致复制失败。

- 如果有两个存储卡可以直接接在同一台电脑上，则可以使用 ``dd`` 命令直接复制

- 这里我只有一个TF转接卡，所以我先把原先的Jetson Nano的TF卡复制成压缩打包文件::

   sudo dd if=/dev/rdisk2 conv=sync,noerror bs=100m | gzip -c > ~/jetson_image.img.gz

.. note::

   这里的 ``dd`` 命令是在 macOS上执行，所以和Linux参数上略有差异。

- 打包成功以后，换成新的目标TF卡，再执行以下命令恢复备份::

   sudo gunzip -c ~/jetson_image.img.gz | dd of=/dev/rdisk2 bs=100m

完成恢复之后，使用新的TF卡启动Jetson Nano，验证是否成功。

参考
=====

- `Clone SD Card – Jetson Nano and Xavier NX <https://www.jetsonhacks.com/2020/08/08/clone-sd-card-jetson-nano-and-xavier-nx/>`_
