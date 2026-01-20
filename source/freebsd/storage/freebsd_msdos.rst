.. _freebsd_msdos:

=====================
FreeBSD DOS文件系统
=====================

我使用 :ref:`blackberry_q10` 尝试实现 ``断舍离`` ，其中SD卡文件系统需要使用FAT文件系统:

- FAT32： 兼容性最强，原生支持。由于 Q10 的年代背景，这是它的“母语”级别支持。
- exFAT： 理论上支持（尤其是 64GB 及以上容量的卡），但在 BB10 停服后的今天，exFAT 偶尔会触发系统要求“格式化”的错误，稳定性不如 FAT32。

FreeBSD支持 ``msdos`` 文件系统包含了 FAT32 支持，并且可以强制在SD卡大于32GB时依然可以强制将其格式化为 FAT32

- 当SD卡通过转接卡插入FreeBSD系统后，可以通过 ``dmesg`` 看到系统信息如下:

.. literalinclude:: freebsd_msdos/dmesg
   :caption: 检查系统日志确定SD卡的设备名

可以看到SD卡被识别为 ``/dev/da0``

- 清理分区表，将分区表设为传统的 MBR 格式，因为老旧的黑莓固件对 GPT 的支持并不完美:

.. literalinclude:: freebsd_msdos/gpart
   :caption: 分区表

- 创建分区(slice):

.. literalinclude:: freebsd_msdos/gpart_add_fat32
   :caption: 添加FAST32分区

- 格式化分区: ``-F 32`` 强制制定为FAT32，并通过 ``-L BLACKBERRY`` 设定标签

.. literalinclude:: freebsd_msdos/newfs_msdos
   :caption: 格式化分区

- 挂载:

.. literalinclude:: freebsd_msdos/mount
   :caption: 挂载分区

参考
======

- google gemini
