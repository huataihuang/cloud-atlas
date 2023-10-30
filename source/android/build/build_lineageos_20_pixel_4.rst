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

.. literalinclude:: build_lineageos_20_pixel_4/git
   :caption: 配置git

- 初始化android仓库以及获取源代码:

.. literalinclude:: build_lineageos_20_pixel_4/repo_sync
   :caption: 初始化android仓库以及获取源代码

这里我遇到一个提示:

.. literalinclude:: build_lineageos_20_pixel_4/repo_sync_err
   :caption: 初始化android仓库以及获取源代码

按照提示复制升级 ``repo`` ::

   cp /home/admin/android/lineage/.repo/repo/repo /home/admin/bin/repo

然后重新执行仓库同步::

   repo init -u https://github.com/LineageOS/android.git -b lineage-20.0

.. note::

   访问GitHub仓库可能受到GFW干扰，所以需要采用 :ref:`git_proxy`

.. note::

   ``repo sync`` 同步命令默认参数是 ``-j 4 -c`` 表示:

   - ``-j 4`` 表示并发4个同步线程(连接)
   - ``-c`` 表示 ``repo`` 值同步当前分支而不是GitHub上该仓库的所有分支

   LineageOS 建议使用默认配置，不过我发现由于翻墙网络非常缓慢，适当增加同步并发可以加快同步。例如 ``repo sync -j 20``

- 准备设备特定代码:

.. note::

   这里针对 :ref:`pixel_4` 设备编译源代码，对应的code名字是 ``flame``

.. literalinclude:: build_lineageos_20_pixel_4/breakfast
   :caption: 同步设备特定代码

参考
======

- `Build LineageOS for Google Pixel 4 <https://wiki.lineageos.org/devices/flame/build>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
