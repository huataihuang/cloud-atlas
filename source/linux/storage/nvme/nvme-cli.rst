.. _nvme-cli:

=================
nvme-cli用户工具
=================

由于数据中心需要很多监控SSD健康度和耐用度，以及更新firmware，安全擦除数据，读取设备日志等管理功能， NVMe组织 <https://nvmexpress.org/>`_ 开发了Linux用户空间命令行工具 ``nvme-cli`` ，可以在Linux系统中管理NVM-Express设备。

.. note::

   有关NVMe监控、管理和故障报告，请参考 :ref:`nvme_ssd_management`

安装
=====

源代码编译安装
----------------

- clone源代码是需要 ``libnvme`` 子模块，所以使用以下命令clone::

   git clone --recurse-submodules https://github.com/linux-nvme/nvme-cli

- 如果没有使用上述包含子模块方式clone但已经clone过源代码，则可以使用以下命令重新初始化并更新::

   git submodule update --init

当然，上述命令也可以分为2个命令执行::

   git submodule init
   git submodule update

- 编译安装::

   make
   make install

发行版安装
---------------

主要的Linux发行版都包含了 ``nvme-cli`` ，可以使用对应包管理器安装：

- Debian/Ubuntu安装::

   sudo apt insall nvme-cli

使用
=======

.. csv-table:: nvme-cli 命令案例和说明
      :file: nvme-cli/nvme-cli.csv
      :widths: 25, 75
      :header-rows: 1

- 列出系统所有安装的NVMe SSD::

   sudo nvme list

在我的 :ref:`hpe_dl360_gen9` 上通过 :ref:`pcie_bifurcation` 安装了3根 :ref:`samsung_pm9a1` :

.. literalinclude:: nvme-cli/nvme_list.txt
   :language: bash
   :linenos:
   :caption: nvme list 输出

- 检查NVMe控制器以及支持的功能::

   sudo nvme id-ctrl /dev/nvme0

输出类似:

.. literalinclude:: nvme-cli/nvme_id-ctrl.txt
   :language: bash
   :linenos:
   :caption: nvme id-ctrl 输出

- 重要: 检查NVMe SMART健康状态，温度等::

   sudo nvme smart-log /dev/nvme0n1

输出:

.. literalinclude:: nvme-cli/nvme_smart-log.txt
   :language: bash
   :linenos:
   :caption: nvme smart-log 输出

- 检查firmware 日志页面::

   sudo nvme fw-log /dev/nvme0n1

输出:

.. literalinclude:: nvme-cli/nvme_fw-log.txt
   :language: bash
   :linenos:
   :caption: nvme fw-log 输出

- 输出NVMe错误日志页面::

   sudo nvme error-log /dev/nvme0n1

输出部分案例:

.. literalinclude:: nvme-cli/nvme_error-log.txt
   :language: bash
   :linenos:
   :caption: nvme error-log 输出

- (警告：我没有使用过)重置NVMe controller / NVMe SSD::

   sudo nvme reset /dev/nvme0n1

NVMe Namespace解析
===================

NVMe的namespace就是NVMe技术中用于存储用户数据的结构。一个NVMe可以具有多个namespace。不过大多数情况下，现在NVMe只使用一个namespace。但是，如果是多租户(multi-tenant)应用程序，虚拟化以及安全要求等业务场景，需要使用多名字空间(multiple namespaces)。

所谓namespace就是一组逻辑块，这些逻辑块地址范围从0到这个namespace的size; 名字空间ID (namespace ID, NSID)是控制器用来访问该名字空间的标识。

你会发现namespace的size和namespace的utilization(使用)对于生成LBA使用的比例非常有用。在标识namespace的命令输出的有用数据中能够用来优化主机软件的性能、数据一致性，TRIM(回收),LBA大小(例如512B,4kB)等等

- 检查NVMe的namesapce::

   sudo nvme id-ns /dev/nvme0n1

输出:

.. literalinclude:: nvme-cli/nvme_id-ns.txt
   :language: bash
   :linenos:
   :caption: nvme id-ns 输出

更新firmware
================

SSD厂商通常会在SSD的生产周期内多次发布firmware更新，不过一个SSD的5年生命期发布4~5次更新则很少见。firmware更新可以提供安全补丁，bug修复以及可靠性提高。OEM通常使用自己的管理工具来更新，比且会加密签名firmware以确保匹配其OEM产品，不过NVMe SSD可以从渠道分销获得通用firmware进行更新。请联系SSD供应商获取最新firmware。

请参考 NVMe 1.4 规范的 ``Firmware Update Process`` 部分，可以详细了解在哪里需要reset，firmware slot的概念(一些NVMe SSD有多个firmware副本存储在设备上，可以通过激活指定副本来运行，这样出现问题可以回退)

- 查看当前firmware版本::

   sudo nvme id-ctrl /dev/nvme0 | grep "fr "

可以看到firmware版本::

   fr        : GXA7401Q

- 下载firmware到目标设备::

   nvme fw-download /dev/nvme0 -
   nvme fw-commit /dev/nvme0 -a 0

这里 ``-a`` 参数:

  - ``0`` 表示将镜像替换掉 ``Firmware slot`` 字段指定的镜像，这个镜像没有激活
  - ``1`` 将镜像替换掉 ``Firmware slot`` 字段指定的镜像，这个镜像在下次reset时激活
  - ``2`` 通过 ``Firmware slot`` 字段制定的镜像在下次reset时激活
  - ``3`` 立即激活 ``Firmware slot`` 字段指定的镜像，无需reset

- 完成firmware下载之后，需要reset设备(如果这个设备不支持无需reset设备就激活镜像)::

   sudo nvme reset /dev/nvme0

.. warning::

   实际上firmware升级需要非常谨慎，我还没有机会实践，以上仅是一些资料整理，后续有机会再实践

参考
======

- `NVMe management command line interface <https://github.com/linux-nvme/nvme-cli>`_
- `Open Source NVMe™ Management Utility – NVMe Command Line Interface (NVMe-CLI) <https://nvmexpress.org/open-source-nvme-management-utility-nvme-command-line-interface-nvme-cli/>`_
