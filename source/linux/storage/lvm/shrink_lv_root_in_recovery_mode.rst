.. _shrink_lv_root_in_recovery_mode:

===============================================
在Recovery模式下收缩系统根目录的LVM逻辑卷(LV)
===============================================

我在 :ref:`incus_zfs` 实践中，需要将操作系统根目录所在的 ``/dev/ubuntu-vg/ubuntu-lv`` 逻辑卷LV收缩，以便能够创建一个用于 :ref:`zfs` 存储池的新LV逻辑卷。

操作的关键是 ``lvreduce`` 需要确保根文件系统卸载状态才能 ``resize2fs`` ，所以最简单的方式是 :strike:`进入Recovery模式，这样可以避免挂载根文件系统，也就能够shrink EXT4文件系统。`

- 重启主机，在物理主机POST自检完成后，立即长按 ``Shift`` 键，强制唤醒GRUB引导菜单
- 在GRUB菜单中，使用方向键选择 ``Advanced options for Ubuntu`` 并回车
- 选择带有 recover mode 的最新内核( ``Ubuntu, with Linux 6.8.0-124-generic (recovery mode)`` )，进入recovery模式

.. warning::

   实践发现进入recovery模式以后，根文件系统实际已经挂载，这导致我最初想要在recovery模式下shrink根文件系统失败。所以改为手工修订启动参数

- 再次重启熊，在选择 recover mode 的最新内核( ``Ubuntu, with Linux 6.8.0-124-generic (recovery mode)`` ) 时，不要回车直接进入，而是按下 ``e`` 进入GRUB脚本编辑模式

- 将光标移动到 ``linux`` 开头的行，将 ``root=`` 等内容清除掉，并在行尾提啊家 ``init=/bin/sh`` ，即修改

.. literalinclude:: shrink_lv_root_in_recovery_mode/linux
   :caption: 原本的linux行配置

- 然后按下 ``ctrl-x`` 引导启动，并看到提示符号如下

.. literalinclude:: shrink_lv_root_in_recovery_mode/initramfs
   :caption: 看到initramfs提示符

.. note::

   此时系统的系统提供了一个shell，但是没有挂载根文件系统，所以能够操作磁盘。注意，这是一个简单的运维环境，缺少很多常用的工具

- 执行以下命令，激活LVM，并检查文件系统和收缩LV:

.. literalinclude:: shrink_lv_root_in_recovery_mode/lvreduce
   :caption: 收缩LV

.. warning::

   这里我实际上遇到了一个问题，就是Ubuntu发行版的 ``initramfs`` 实际上缺少维护LVM的工具，例如执行 ``lvreduce`` 命令实际上该工具没有集成在initramfs中。所以上述执行过程会报错，如果要通过这种方式，实际上要自己重构initramfs，将必要的哦凝固集成进去。

   所以，我最终改成采用 Ubuntu Live CD 来完成上述操作，其步骤区别仅仅是启动方式不同。
