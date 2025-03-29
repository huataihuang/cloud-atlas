.. _lfs_finish:

===================
LFS收尾工作
===================

一切就绪，在启动前为系统再增加一些描述配置文件

- ``/etc/lfs-release`` :

.. literalinclude:: lfs_finish/release
   :caption: 增加release信息

- 按照Linux Standards Base(LSB)增加系统描述:

.. literalinclude:: lfs_finish/lsb
   :caption: 增加LSB信息

- 创建systemd和图形桌面使用的信息:

.. literalinclude:: lfs_finish/os-release
   :caption: 增加os-release信息


