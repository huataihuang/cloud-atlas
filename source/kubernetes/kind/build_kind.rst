.. _build_kind:

=================
编译Kind
=================

本文尝试使用 kind Git仓库最新源代码编译，以便能够从修复 :ref:`debug_mobile_cloud_x86_kind_create_fail` 构建包含 ``zfs`` 工具的镜像

.. note::

   我清理掉了所有本地kind镜像，从最初开始

- 下载kind源代码并进行编译:

.. literalinclude:: build_kind/build_kind_from_git_source
   :language: bash
   :caption: 从kind的git源代码编译

异常问题
============

这里我遇到一个问题，在 ``make quick`` 尝试创建 ``base-image`` 时候会报错，显示 ``zfs fs destroy`` 容器目录出现数据集正忙，无法删除而退出::

   ERRO[0024] Error waiting for container: container c32a66a9a8e573412126728b5215edc2eb819b8af22efee5e4cedb1041d87108: driver "zfs" failed to remove root filesystem: exit status 1: "/usr/bin/zfs fs destroy -r zpool-data/05f8135122b3ccd853a663dee5b8a0d1e50d1c8c4449ba7401e33cee70b54771" => cannot destroy 'zpool-data/05f8135122b3ccd853a663dee5b8a0d1e50d1c8c4449ba7401e33cee70b54771': dataset is busy
   make: *** [/home/huatai/docs/xcloud-env/kind/images/base/../Makefile.common.in:51: ensure-buildx] Error 125

另外, ``zfs list`` 显示大量的残留容器目录没有删除，晕倒::

   NAME                                                                               USED  AVAIL     REFER  MOUNTPOINT
   zpool-data                                                                        22.0G   839G     3.15G  /var/lib/docker
   zpool-data/05f8135122b3ccd853a663dee5b8a0d1e50d1c8c4449ba7401e33cee70b54771         21K   839G     18.4M  legacy
   zpool-data/05f8135122b3ccd853a663dee5b8a0d1e50d1c8c4449ba7401e33cee70b54771-init    25K   839G     18.4M  legacy
   zpool-data/0e7zhf1ohmfdfgqnsq1gy0b7n                                                62K   839G     43.0M  legacy
   zpool-data/15a80a720bcf7652b1b49a513a4bef6efd44eca38be6a0de12afabc6516e6611       74.5M   839G     74.5M  legacy
   zpool-data/197f30ff6351df25493a07bba14c4872e7409532249ac7e93301a8f58cbeda06       80.6M   839G      172M  legacy
   zpool-data/23ah042ipkjm8onfidhzu7ebt                                              7.35M   839G     2.87G  legacy
   zpool-data/247gg7t6mnbvd291ms37wxyu1                                               126K   839G     2.87G  legacy
   zpool-data/2c112dc17d1ed7b8a2172e6d3756cef1906714cbc6b2b16acde22f0e119fd5cd       2.64M   839G     2.89G  legacy
   ...

我想了一下，应该是很多次创建和删除 ``kind`` 的容器，但是这些容器内部都没有 ``zfs`` 工具，所以不能清理掉残留的容器

.. note::

   暂时没有时间和精力折腾了，我觉得这个构建需要在普通文件系统上完成(将镜像中加入zfs工具)，但是直接在zfs文件系统上build不行。还是等待下一个发布版本后再折腾
