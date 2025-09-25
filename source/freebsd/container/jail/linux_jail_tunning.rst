.. _linux_jail_tunning:

=========================
FreeBSD Linux Jail优化
=========================

Ubuntu调整 ``APT::Cache-Start``
=================================

在完成 :ref:`linux_jail_ubuntu-base` 部署之后，在Linux Jail中的Ubuntu环境中执行 ``apt update`` ，出现如下报错:

.. literalinclude::  linux_jail_tunning/apt_cache-start_error
   :caption: 在Ubuntu Linux Jail中执行 ``apt update`` 报错

虽然Google AI提示可以通过 ``/etc/apt/apt.conf.d/99custom-cache`` 配置文件:

.. literalinclude::  linux_jail_tunning/99custom-cache
   :caption: ``/etc/apt/apt.conf.d/99custom-cache`` 配置文件调整 ``APT::Cache-Limit``

没有解决，但是我看到 `apt update报错E: Dynamic MMap ran out of room <https://blog.csdn.net/skywalk8163/article/details/140383232>`_  提供的方法直接增大 ``APT::Cache-Start`` 到 ``64MB`` ，也就是最终配置:

.. literalinclude::  linux_jail_tunning/99custom-cache_ok
   :caption: 最终解决的配置 ``APT::Cache-Start`` 设置 ``64MB``

则实践 ``apt update`` 成功

参考
======

- `apt update报错E: Dynamic MMap ran out of room <https://blog.csdn.net/skywalk8163/article/details/140383232>`_
