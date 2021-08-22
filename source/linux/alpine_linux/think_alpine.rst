.. _think_alpine:

=====================
Alpine Liunx思考
=====================

在初次尝试了Alpine Linux之后，我发现这个发行版比较有特色:

- 面向服务器，采用 ``Small, Simple, Secure`` 策略，尽可能减少不必要的软件堆栈和复杂配置，这一方面使得系统更稳定和安全，另一方面也降低了系统开销
- 具有Debian相似的系统包管理 :ref:`alpine_apk` ，方便运维升级

在对比使用了 ``Stand`` 和 ``Extended`` 版本之后，我觉得更应使用 ``Extended`` 版本，主要依据：

- ``Extended`` 版本只使用U盘，启动后整个系统运行在RAM中，所以除了启动稍慢(受限于U盘读写)，启动后在内存中读写文件系统非常快速
- 可以以 ``data`` 模式挂载物理主机的本地磁盘，这样持久化数据不会丢失
- 个人测试 :ref:`studio` 采用 ``Extended`` 版本Alpine Linux，可以快速恢复系统(所有配置和数据采用自己构建的 :ref:`ceph` 和 :ref:`gluster` 保存，本地挂载到映射目录)

- 适合中小型数据中心使用

  - 只需要使用小容量的U盘就可以快速复制大量的alpine系统，即插即用
  - 服务器故障，只需要将U盘换到替换服务器上就可以快速恢复(适合本地无重要数据环境)
  - 重要业务数据采用 :ref:`ceph` 和 :ref:`gluster` 保存( :ref:`real_private_cloud_think` )