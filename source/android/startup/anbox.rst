.. _anbox:

=======================
Anbox运行Andorid程序
=======================

Anbox是开源兼容层，通过LXC容器构建Android运行环境，使得移动应用程序能偶运行在Linux环境。由于使用容器，采用原生Linux内核执行应用程序，所以非常轻量级并且保障了运行速度。

安装Anbox
===========

- 首先确保系统安装了Linux内核头文件::

   sudo pacman -S linux-headers

- 安装Anbox，如果镜像中不想包含Google apps和houdini，则用 anbox-image 替代 anbox-image-gapps::

   sudo pacman -S anbox-git anbox-image-gapps anbox-modules-dkms-git anbox-bridge

报错处理
=========

- 编译报错::

   /home/huatai/.cache/yay/anbox-git/src/anbox/src/anbox/logger.cpp:20: error: "BOOST_LOG_DYN_LINK" redefined [-Werror]
      20 | #define BOOST_LOG_DYN_LINK

 这个报错解决方法见 https://bbs.archlinux.org/viewtopic.php?id=249747

参考
=======

- `Arch Linux社区文档 - Anbox <https://wiki.archlinux.org/index.php/Anbox>`_
