.. _docker_tmpfs_mount:

================================
Docker内存文件系统(tmpfs)挂载
================================

:ref:`docker_volume` 和 :ref:`docker_bind_mount` 都是在容器和主机之间共享文件的方式，这样即使容器停止和删除，持久化数据依然可以获得。

在运行Docker的Linux系统中，还有一种特殊的基于内存文件系统 ``tmpfs`` 的挂载，可以在容器和主机间共享文件，虽然这种共享文件是非持久化的，即容器停止， ``tmpfs`` 挂载就会移除，则写入 ``tmpfs`` 的文件无法持久化。但是由于交换文件是存储在服务器的内存中，读写性能非常高，特别适合容器和外部交换临时文件，例如，只需要短暂存储就可以被日志采集系统读取完毕而无需长久保存的日志文件。

.. image:: ../_static/docker/types-of-mounts-tmpfs.png

``tmpfs`` 挂载的限制：

- 和 :ref:`docker_volume` 、 :ref:`docker_bind_mount` 不同，不能在容器间共享 ``tmpfs`` （不能使用 ``sidecar`` 方式读取容器共享的日志？）
- ``tmpfs`` 挂载仅限于Linux上运行的Docker



参考
======

- `Use tmpfs mounts <https://docs.docker.com/storage/tmpfs/>`_
