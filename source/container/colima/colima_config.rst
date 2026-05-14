.. _colima_config:

=======================
Colima配置
=======================

Colima使用了 YAML 格式的配置文件:

- ``~/.colima/_templates`` 目录下有一个 ``default.yaml`` 配置文件是所有配置的起点，也就是当创建实例时会从这个模版文件复制出来进行定制
- ``~/.colima/default/colima.yaml`` 是实例配置文件，修订这个配置并保存，Colima会自动重启虚拟机以应用新的硬件规格，之前在虚拟机中安装的二进制文件、容器和本地镜像都会完好无损地保留下来

当使用 ``colima start`` 启动了虚拟机，就会形成 ``~/.colima/default/colima.yaml`` 实例配置，此时需要修订该配置来完成修改。修改模版 ``~/.colima/_template/default.yaml`` 只会影响之后创建的虚拟机。

.. note::

   ``~/.colima/_templates/default.yaml`` 中有详细注释，所以可以比较清晰找到对应设置。本文仅选择部分关注点进行记录和实践

VM规格调整
==============

在 :ref:`colima_startup` 实践中，根据本地host主机硬件可以调整CPU和Memory的规格，由于 :ref:`mbp15_late_2013` 硬件有限，所以我调整为 ``2c4g`` 规格

修改RunTime
===============

默认 :ref:`container_runtimes` 是 :ref:`docker` ，但是考虑到轻量级和 :ref:`kubernetes` 平滑一致，我将默认runtime修订为containerd

修改默认OS
============

Colima底层是 :ref:`lima` ，完整继承了Lima对多发行版的支持(底层实际上是采用了 :ref:`lima_template_config` )，可以通过命令行参数或配置文件，将虚拟机替换为各种主流Linux发行版。

检查 ``~/.colima/_templates/default.yaml`` 可以看到如下配置，其配置方法应该是沿用 :ref:`lima_template_config` :

.. literalinclude:: colima_config/defalut_diskimage.yaml
   :caption: 默认diskImage配置

根据注释可以看到默认是从github获取Ubntu的镜像，所以参考 :ref:`lima_template_config` 应该可以指定其他Linux发行版。后续我准备改成采用 :ref:`debian` 来运行Colima

参考
======

- `colima docs: Configuration <https://colima.run/docs/configuration/>`_
