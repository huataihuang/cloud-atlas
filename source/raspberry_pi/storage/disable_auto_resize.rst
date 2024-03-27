.. _disable_auto_resize:

======================================
关闭自动resize根文件系统
======================================

在使用 :ref:`raspberry_pi` 和 :ref:`ubuntu64bit_pi` 时，你会发现当系统启动时，会自动把根文件系统扩展成占用整个磁盘系统。

这对我部署 :ref:`gluster` 和 :ref:`gluster` 不利，因为我需要自定义文件系统，准备独立的存储卷给存储服务使用。

.. note::

   可能首次镜像安装以后，需要删除掉 ``/.first_boot`` 标记文件，避免第一次启动自动扩展文件系统。

在 Ubuntu for Raspbery Pi 系统中，采用 :ref:`disable_cloud_init` 方法禁止 :ref:`cloud_init` 就可以关闭自动扩展，或者修改 ``cloud-init`` 配置关闭自动扩展。

参考
======

- `Temporarily disable expand filesystem during first boot <https://raspberrypi.stackexchange.com/questions/56621/temporarily-disable-expand-filesystem-during-first-boot>`_
- `Disable auto file system expansion in new Jessie image 2016-05-10 <https://raspberrypi.stackexchange.com/questions/47773/disable-auto-file-system-expansion-in-new-jessie-image-2016-05-10>`_
- `Option to disable automatic "expand File System"? #335 <https://github.com/guysoft/OctoPi/issues/335>`_
- `How to resize root partition in 16.04? <https://forum.odroid.com/viewtopic.php?f=95&t=24592>`_
