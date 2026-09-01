.. _macports_mpv_on_mavericks:

==================================
在Mavericks上使用Macports安装mpv
==================================

准备
======

Mavericks(OS X 10.9)作为古老的macOS，首先需要完成 :ref:`macports_on_mavericks`

安装
======

- 搜索可以安装的软件

.. literalinclude:: macports_mpv_on_mavericks/search
   :caption: 搜索mpv

输出类似:

.. literalinclude:: macports_mpv_on_mavericks/search_output
   :caption: 搜索mpv的输出信息

在Mavericks上必须选择 ``mpv-legacy`` :

  - ``mpv @0.41.0`` (主线最新版)：代码库大量依赖现代 macOS（通常要求 macOS 10.15+ 或 11+）的系统 API、Metal 图形渲染架构以及 C++20 标准。
  - ``mpv-legacy @0.36.0`` (老系统兼容版)：MacPorts 维护者专门为旧版 OS X（如 10.9 / 10.10 等）保留的兼容分支，剥离了对现代 Metal/Cocoa 新 API 的强依赖，完全保留了对 OpenGL 和 VideoToolbox (10.9 硬解) 的支持。
  - ``mpv-legacy`` 能够完美调用 :ref:`mba11_late_2010` GeForce 320M 的 VideoToolbox 硬件解码，在 10.9 上播放 1080p H.264 视频时 CPU 占用率极低。

- 安装

.. literalinclude:: macports_mpv_on_mavericks/install
   :caption: 安装mpv

配置
=======

- 配置文件 ``~/.config/mpv/mpv.conf`` :

.. literalinclude:: macports_mpv_on_mavericks/mpv.conf
   :caption: mpv配置文件
