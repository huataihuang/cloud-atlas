.. _think_blfs:

=====================================
BLFS(Beyond Linux From Scratch)思考
=====================================

:ref:`lfs` 是一个艰难的跋涉过程，我从第一次听到LFS到真正实际完成，中间间隔了很多年，而按照手册一步步完成也是非常枯燥而繁琐的过程，断断续续花费了我可能有一两周时间。

LFS给我的收获主要是对操作系统能够从无到有一个感性认识，虽然我在 :ref:`gentoo_linux` 已经体验过很多这种折腾，但毕竟越底层越能破解迷思。特别是最后的 :ref:`lfs_boot` ，以前没有注意到的技术细节，因为解决一个和手册不同的磁盘挂载而触发我更了解一些GRUB。

之所以在使用Linux这么多年之后，依然来自己编译一个Linux，是因为我想构建一个更为轻巧和敏捷的Linux Host底座:

- 只安装自己运行应用需要的库和程序，定制专用系统:

  - :ref:`blfs_virtualization`
  - :ref:`blfs_container`
  - :ref:`blfs_k8s`
  - :ref:`blfs_desktop`

- 从源代码编译可以迫使自己关注软件体系构成的技术细节，深入了解软件运行的配置细节

我的最终目标是构建一个运行应用的最小化系统，目标专注来降低系统的复杂度、提高系统性能和稳定性，辅助以自己定制的管控运维系统。

BLFS
=========

``BLFS`` 和 :ref:`lfs` 设计理念不同，并不是直接线性执行的:

- LFS只提供一个基本核型系统，在LFS上处于不同目的可以部署不同的系统
- BLFS是指导在LFS之上不同的方向，所以选择在你

:ref:`lfs` 系统是非常核心和基础的系统，然而距离生产应用还有一步之遥:

- 应用软件的编译、安装部署
- 应用软件所带来的增量依赖软件和库的编译、安装
- 持续的迭代更新以及安全补丁

`Beyond Linux From Scratch (System V Edition) <https://www.linuxfromscratch.org/blfs/view/12.2/index.html>`_ 是参考基础，我计划:

- 按需安装我需要的应用服务: 根据我运行的应用来决定安装必要的依赖软件和库，而不是完全按照BLFS的手册
- Host主机只维持运行基本的 :ref:`blfs_virtualization` ，将进一步定制和针对不同环境的定制在虚拟机内部实现 :ref:`blfs_container` 和 :ref:`blfs_k8s`
- 在自己古老的笔记本上尝试构建 :ref:`blfs_desktop` : :ref:`xfce` 或者 :ref:`sway`

在学习和实验的过程中，我主要使用 :ref:`mbp15_2018` 运行 :ref:`apple_virtualization` 框架，因为这是我最好的可以移动使用的电脑。

.. warning::

   我的实践只摘要我关注和使用的BLFS部分，所以并不是完整的指南。详情请参考官方原文!

准备工作
==========

- 软件包列表

.. literalinclude:: think_blfs/blfs_filelist.txt
   :caption: 下载文件列表

- 编译顺序:

.. literalinclude:: think_blfs/build_order.txt
   :caption: 编译顺序
