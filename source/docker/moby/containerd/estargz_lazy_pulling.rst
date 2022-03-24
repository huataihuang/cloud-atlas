.. _estargz_lazy_pulling:

============================================================
用于延迟拉取(Lazy Pulling)的eStargz(容器镜像层标准兼容扩展)
============================================================

在 Kubernetes 运行中，镜像拉取始终是决定容器启动速度的重要因素。特别是很多应用运维不注重 :ref:`smaller_docker_images` ，会导致容器启动时出现大量并发拉取超大镜像，阻塞网络，触发系统故障。

在 `OCI镜像规范 <https://github.com/opencontainers/image-spec/>`_ 和 `Docker镜像规范 <https://github.com/moby/moby/blob/master/image/spec/v1.2.md>`_ 的 ``application/vnd.docker.image.rootfs.diff.tar.gzip`` 提供了容器镜像的 ``gzip`` 层扩展用于延迟拉取( ``lazy pulling`` )，这个扩展被称为 ``eStargz`` 。

eStargz是一个向后兼容的扩展，也就是说镜像可以被发不到无扩展感知的仓库，也可以被运行在无扩展感知能力的runtime上。 ``eStargz`` 扩展给予 ``stargz`` (可检索tar.gz标准， stands for seekable tar.gz)，最初由Google CRFS项目提出。 ``eStargz`` 扩展了stargz的检查层验证以及运行时性能优化。

eStargz概述
============

``Lazy pulling`` 是一种更快冷启动的镜像拉取技术。允许一个容器启动时不需要等待整个镜像层内容完全下载到本地。相反，只要数据层的必要文件(或者大型文件的数据块)被按需下载就可以运行容器。

为了实现这一目标，runtime需要在一个无依赖层中拉取和展开美俄文件。然而，没有eStargz扩展的层不能实现这一目标，原因如下:

- 即使只是包含一个文件的层，整个数据层都需要展开
- 摘要信息(digests)不能提供每个文件信息，所以文件不能独立验证

dStargz解决了上述问题，所以能够用于 ``lazy pulling``

此外，eStargz支持文件预取( ``prefetching`` )，有助于缓解由于按需拉取每个文件导致的运行时性能不足。

eStargz扩展可以向后兼容，所以eStargz格式的镜像也能够推送到常规镜像仓库，并且能呕运行在不支持eStargz的运行时上。

eStargz结构
==============

.. figure:: ../../../_static/docker/moby/containerd/estargz-structure.png
   :scale: 50

参考
=======

- `eStargz: Standard-Compatible Extension to Container Image Layers for Lazy Pulling <https://github.com/containerd/stargz-snapshotter/blob/main/docs/estargz.md>`_
