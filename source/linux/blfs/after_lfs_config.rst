.. _after_lfs_config:

====================
LFS之后的配置
====================

:ref:`lfs` 提供了一个基础系统，不过实际使用时，需要在完成LFS安装部署后，继续做一些补充配置

Firmware
===========

Linux系统要能够在真实硬件上良好运行，需要安装不同厂商提供的硬件firmware:

- CPU微码(microcode): 用于修复CPU漏洞
- GPU firmware: 典型的是三家GPU厂商 - AMD, Intel, Nvidia
- 有线网卡firmware: 通常能够修复问题提升性能
- 其他设备firmware: 例如无线网卡需要特定firmware驱动才能工作

.. _blfs_micorcode:

CPU microcode
-----------------

- 检查CPU信息:

.. literalinclude:: after_lfs_config/cpuinfo
   :caption: 检查CPU信息


- 检查当前微码(还没有更新之前):

.. literalinclude:: after_lfs_config/microcode_before
   :caption: 更新前的CPU微码

- 从 `Intel-Linux-Processor-Microcode-Data-Files <https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files/releases/>`_ 下载最新微码

.. note::

   在执行 构建 ``microcode.img`` 前，先完成 :ref:`blfs_cpio` 安装

- 构建 ``microcode.img`` :

.. literalinclude:: after_lfs_config/microcode.img
   :caption: 构建 ``microcode.img``

- Intel发布的微码 ``releasenote.md`` 中有说明可检查

.. csv-table:: Intel微码 ``releasenote.md`` 更新 Xeon E5 v3
   :file: after_lfs_config/microcode.csv
   :widths: 10,10,20,10,10,40
   :header-rows: 1

.. note::

   在执行 ``/boot/grub/grub.cfg`` 中添加 ``initrd`` 配置 前，先查看一下 :ref:`blfs_initramfs` 是否有必要一起完成。

   目前我还没有使用 ``initramfs`` ，仅加载 CPU microcode : 后续有需要在补充添加 :ref:`blfs_initramfs` (可以补充在cpu microcode 的 ``initrd`` 后面加载

   另外，如果 ``intel-ucode`` 微码目录完整复制到 ``/lib/firmware`` 目录下，那么 **也可以** 不用执行下面一步 在 ``/boot/grub/grub.cfg`` 中添加 ``initrd`` 配置 ，直接执行 :ref:`blfs_initramfs` 中 ``mkinitramfs`` 会自动添加cpu microcode。

- 在 ``/boot/grub/grub.cfg`` 中添加 ``initrd`` 配置:

.. literalinclude:: after_lfs_config/grub.cfg
   :caption: 配置 grub.cfg
   :emphasize-lines: 4

-  重启系统，然后检查:

.. literalinclude:: after_lfs_config/dmesg
   :caption: 检查启动系统输出

由于我的系统CPU在之前 :ref:`ubuntu_linux` 安装运行时已经自动更新过CPU microcode，所以这里没有更新信息，还是 ``0x00000049`` (也是之前检查 ``releasenote.md`` 可以看到最高版本)

.. literalinclude:: after_lfs_config/dmesg_output
   :caption: 检查启动系统输出显示CPU微码更新情况

网卡firmware
---------------

待补充...

Bash Shell启动文件
======================

参考
=====

- `After LFS Configuration Issues <https://www.linuxfromscratch.org/blfs/view/stable/postlfs/config.html>`_
