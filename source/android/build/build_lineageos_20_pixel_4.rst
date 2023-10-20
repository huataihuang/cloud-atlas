.. _build_lineageos_20_pixel_4:

=======================================
为Pixel 4编译LineageOS 20(Android 13)
=======================================

准备工作
==========

- ref:`android_build_env_ubuntu`

安装仓库
==========

- 创建目录并下载安装仓库:

.. literalinclude:: build_lineageos_20_pixel_4/repo
   :caption: 创建repo

- 配置 ``~/bin`` 到执行目录(添加到 ``~/.profile`` )

.. literalinclude:: build_lineageos_20_pixel_4/profile
   :caption: 将repo的 ``~/bin`` 路径添加到 ``~/.profile``

- 配置 ``git`` :

参考
======

- `Build LineageOS for Google Pixel 4 <https://wiki.lineageos.org/devices/flame/build>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
