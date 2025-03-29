.. _blfs_networking_programs:

===============================
BLFS Networking Programs
===============================

bridge-utils
================

``bridge-utils`` 是创建和管理bridge设备的工具

- 可选依赖:

  - ``net-tools`` (也就是 ``ifconfig`` 这样的工具，我目前继续使用 :ref:`iproute2` 也就是 :ref:`ip` 命令)

内核设置
----------

内核需要编译支持 ``802.1d Ethernet Bridging`` :

.. literalinclude:: blfs_networking_programs/kernel
   :caption: 内核支持 ``802.1d Ethernet Bridging``

安装
------

.. literalinclude:: blfs_networking_programs/bridge-utils
   :caption: 安装 bridge-utils

.. _bridge_br0_config:

bridge配置 ``br0``
--------------------

为了实现bridge的自动创建和配置，安装 ``blfs-bootscripts-20240416`` 中的 ``/usr/lib/services/bridge`` 服务，然后配置一个初始化 ``br0`` 虚拟交换机:

.. literalinclude:: blfs_networking_programs/br0
   :caption: 构建 ``br0`` 虚拟交换机

重启系统以后检查 ``ifconfig`` 输出，可以看到新增了一个 ``br0`` 虚拟机交换机，并且和 ``eno1`` 连接:

.. literalinclude:: blfs_networking_programs/br0_eno1
   :caption: 重启系统后检查
   :emphasize-lines: 2,10,28

.. note::

   手工配置也可以参考 :ref:`qemu_simple_bridge_network`

使用
------

- :ref:`run_debian_in_qemu`
- :ref:`run_debian_gpu_passthrough_in_qemu`
- :ref:`gpu_passthrough_in_qemu_install_nvidia_cuda`
- :ref:`qemu_docker_tesla_t10`

wget
==========

.. literalinclude:: blfs_networking_programs/wget
   :caption: 安装 wget
