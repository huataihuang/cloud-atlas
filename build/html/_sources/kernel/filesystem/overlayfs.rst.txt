.. _overlayfs:

==================
OverlayFS文件系统
==================

OverlayFS是一种union文件系统，允许在一个文件系统之上再部署一个文件系统，通过修改上层文件系统，可以保持底层的文件系统不被修改。例如，可以让多个用户共享一个文件系统镜像，诸如容器或一个DVD-ROM，底层镜像是一个只读介质。

Docker和OverfsFS
====================

OverlayFS只作为Docker graph driver，只支持作为容器COW内容，而不能作为持久化存储(OverlayFS性能很差)。所有持久化存储必须存储到非OverlayFS卷，默认Docker配置就使用OverlayFS。此外，底层和上层使用相同文件系统，所以需要注意:

- XFS作为 ``Backing Filesystem`` 时，必须激活 ``d_type=true`` ，也就是格式化时候使用参数 ``-n ftype=1`` ，案例请参考 :ref:`xfs` 实践案例
- Docker的OverlayFS实践见 :ref:`docker_overlay_driver`

参考
======

- `Red Hat Enterprise Linux77.2 Release NotesChapter 21. File Systems <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/7.2_release_notes/technology-preview-file_systems>`_
- `Kernel document: overlayfs.txt <https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt>`_
- `Use the OverlayFS storage driver <https://docs.docker.com/storage/storagedriver/overlayfs-driver/>`_
