.. _build_pcm:

================
编译Intel PCM
================

编译
========

- clone CPM代码仓库以及子模块:

.. literalinclude:: build_pcm/build_pcm
   :caption: 编译CPM的简单步骤

在CentOS 7,2平台编译
======================

生产环境使用了古老的(类)CentOS 7.2环境，在这个旧OS中编译会比较折腾(无力吐糟)

- 默认CentOS 7使用的CMaker版本是 2.8.12.2 ，CPM编译时会提示要求 CMake 3.5或更高版本，所以要从 `cmake官方下载 <https://cmake.org/download/>`_ 最新版本自己 :ref:`upgrade_cmake_on_centos7`

- Intel PCM使用了 `simdjson(Github) <https://github.com/simdjson/simdjson>`_ ，而 ``simdjson`` 需要使用现代化的编译器(LLVM clang 6 or better, GNU GCC 7.4 or better, Xcode 11 or better) ，所以需要 :ref:`upgrade_gcc_on_centos7`

- 编译步骤同上

文件打包
========

为了方便安装，根据 ``make install`` 列出文件，记录到 ``files.txt`` 中，然后执行以下命令打包成 ``cpm.tar.gz`` (参考 `Tar archiving that takes input from a list of files <https://stackoverflow.com/questions/8033857/tar-archiving-that-takes-input-from-a-list-of-files>`_ ，此外同时打包 :ref:`pcm-exporter` 的 ``/etc/systemd/system/pcm-exporter.service`` ):

.. literalinclude:: build_pcm/tar_pcm_tar
   :caption: 根据文件列表打包pcm安装文件

然后在目标服务器上只需要执行以下命令就能快速运行 ``pcm-exporter`` 服务:

.. literalinclude:: build_pcm/deploy_pcm
   :caption: 快速部署自己编译的pcm-exporter

也可以通过类似 :ref:`homebrew` 方法执行脚本安装:

.. literalinclude:: build_pcm/install_pcm.sh
   :language: bash
   :caption: 快速在被监控节点部署安装 Intel PCM 的脚本 ``install_pcm.sh``

.. literalinclude:: build_pcm/curl_install_pcm
   :language: bash
   :caption: crul 执行安装 脚本 ``intall_pcm.sh``

问题排查
==========

遇到一个问题，使用 :ref:`pcm-exporter` 中 :ref:`systemd` 配置方式启动 ``pcm-sensor-server`` 失败:

.. literalinclude:: build_pcm/systemd_start_pcm-server_fail
   :caption: 使用 systemd 启动自己编译的 pcm-sensor-server 失败

我发现是参数 ``--real-time`` 导致，原因未明，通过取消该参数恢复

参考
======

- `Intel Performance Counter Monitor (Intel PCM) (GitHub) <https://github.com/intel/pcm>`_
