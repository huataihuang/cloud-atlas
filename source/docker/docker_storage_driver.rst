.. _docker_storage_driver:

======================
Docker存储驱动
======================

为了高效使用存储驱动，理解Docker如何构建和存储镜像以及镜像如何被容器使用是非常重要的。只有理解Docker存储驱动的原理才能合理选择应用程序的持久化数据方案并避免性能问题。

Docker存储驱动( ``storage drivers`` )允许在容器中创建可以存储数据的可写入数据层，但是需要注意的是，通过存储驱动读写docker文件层的 ``性能低下`` ，并且在 ``容器删除时数据丢失`` 。

``缓慢的 storage drivers`` :

.. image:: ../_static/docker/docker_storage_driver_sloth.png
   :scale: 50
   :target: http://en.wikifur.com/wiki/Sloth_(species)

.. note::

   持久性数据和高性能读写情况下，需要选择 :ref:`docker_volume`

参考
========

- `About storage drivers <https://docs.docker.com/storage/storagedriver/>`_
- `Container Storage Best Practices in 2017 <https://www.slideshare.net/KeithResar/container-storage-best-practices-in-2017>`_
