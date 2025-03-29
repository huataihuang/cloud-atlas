.. _create_boot_usb_from_iso_in_mac:

=================================
在macOS中使用iso文件创建启动U盘
=================================

有时候我们需要在macOS中制作启动U盘，例如 :ref:`freebsd_on_intel_mac` 或者需要安装Linux主机。从网上下载的启动安装镜像文件是 ``.iso`` 也就是光盘镜像，不想刻光盘，只想制作启动U盘以便能反复使用U盘制作不同启动安装盘。

- macOS的Disk Utility提供了一个转换iso文件的方法，以 :ref:`freebsd_on_intel_mac` 下载的镜像为例:

.. literalinclude:: create_boot_usb_from_iso_in_mac/hdiutil_convert_iso
   :language: bash
   :caption: 使用hdiutil转换iso文件到镜像文件dmg

- 然后检查插入U盘的挂载(通常Windows兼容U盘插入时会自动挂载)::

   df -h

看到输出可能类似如下::

   ...
   /dev/disk2s1                        30Gi   11Mi   30Gi     1%       0          0  100%   /Volumes/U

则手工卸载U盘::

   diskutil umountDisk /Volumes/U

- 执行镜像写入(注意转换后的 ``.img`` 文件会自动加上 ``.dmg`` 后缀):

.. literalinclude:: create_boot_usb_from_iso_in_mac/dd_img
   :language: bash
   :caption: 使用dd命令将img文件写入U盘
