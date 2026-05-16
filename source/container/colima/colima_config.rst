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

参数解析
============

VM规格调整
----------------

在 :ref:`colima_startup` 实践中，根据本地host主机硬件可以调整CPU和Memory的规格，由于 :ref:`mbp15_late_2013` 硬件有限，所以我调整为 ``2c4g`` 规格

修改RunTime
----------------

默认 :ref:`container_runtimes` 是 :ref:`docker` ，但是考虑到轻量级和 :ref:`kubernetes` 平滑一致，我将默认runtime修订为containerd

修改默认OS(diskImage)
------------------------

Colima底层是 :ref:`lima` ，完整继承了Lima对多发行版的支持(底层实际上是采用了 :ref:`lima_template_config` )，可以通过命令行参数或配置文件，将虚拟机替换为各种主流Linux发行版。

检查 ``~/.colima/_templates/default.yaml`` 可以看到如下配置，其配置方法应该是沿用 :ref:`lima_template_config` :

.. literalinclude:: colima_config/defalut_diskimage.yaml
   :caption: 默认diskImage配置

根据注释可以看到默认是从github获取Ubntu的镜像，所以参考 :ref:`lima_template_config` 应该可以指定其他Linux发行版。后续我准备改成采用 :ref:`debian` 来运行Colima

设置主机名
--------------

``hostname`` 变量可以设置模版默认的主机名，如没有设置默认是 ``colima``

启用Kubernetes
----------------

提供了一个启用 :ref:`k3s` 运行kubernetes模拟集群，方便快速开发和测试，并且提供了一些可调整设置，其中包含了可以指定绑定网卡接口(对于多网卡)

Network
----------

Network 段落设置提供了调整 macOS 环境(Linux忽略)的 ``shared`` 或 ``bridged`` 模式

vm类型
-------------

``vmType`` 默认使用 :ref:`qemu` ，对于macOS 13以上可以指定 ``vz`` 类型，性能更好

``mountType`` 对于 ``vz`` 虚拟机默认使用 ``virtiofs`` ，对于 ``qemu`` 虚拟机默认使用 ``sshfs`` ，其中 ``virtiofs`` 性能较好

最终配置
===========

.. literalinclude:: colima_config/default.yaml
   :caption: 修订 ``default.yaml``

.. note::

   每次修订 ``~/.colima/_template/default.yaml`` ，只有再次创建虚拟机才会读取这个默认模版，之前已经创建的vm不受影响。所以如果要修订已经创建的虚拟机，需要执行删除再启动:

   .. literalinclude:: colima_config/delete_start
      :caption: 删除虚拟机再创建虚拟机

创建容器运行环境
==================

.. note::

   注意在国内访问github存在障碍，需要配置 :ref:`colima_proxy`

- 修订 ``~/.colima/default/colima.yaml`` 添加socks代理

.. literalinclude:: colima_config/colima_proxy.yaml
   :caption: 配置代理

.. warning::

   实践发现，在 ``~/.colima/default/colima.yaml`` 配置 ``env`` 使用 ``ALL_PROXY`` 对于colima自身下载镜像没有作用，需要配置 ``http_proxy`` 和 ``https_proxy`` 才能生效。看来底层是采用 :ref:`curl` ，其优先级是小写的 ``http_proxy`` 和 ``https_proxy`` 优先级最高

- 执行启动:

.. literalinclude:: colima_startup/colima_start
   :caption: 启动colima

启动不带任何参数，colima就会从 ``~/.colima/_tempalate/default.yaml`` 读取配置并形成 ``~/.colima/default/colima.yaml`` 配置。例如上文设置了模版中的代理配置，也会带入到默认配置中

参考
======

- `colima docs: Configuration <https://colima.run/docs/configuration/>`_
