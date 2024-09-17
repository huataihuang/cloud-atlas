.. _raspberry_pi_os_init:

===================================
Raspbery Pi OS(Raspbian)软件初始化
===================================

:ref:`raspberry_pi_os` 系统安装完成后，根据不同需求环境，进行软件安装

.. note::

   我的实践是安装 ``Raspberry Pi OS Lite 仅包含核心操作系统`` ，所以本文实践都是在这个基础上完成的。如果你安装完整桌面版本，则会和我的情况不同

底层OS基础应用
=================

我的 :ref:`pi_5` 是作为一个物理底座来运行，也就是说:

- 保持物理主机操作系统最小精简化，只安装必要的维护工具
- 所有应用都通过 :ref:`docker` 或 :ref:`kvm` 在 容器/虚拟机 中运行，所以物理主机OS不需要复杂部署，力求精简化方便迁移应用

:ref:`raspberry_pi_os` Lite版本默认已经安装了很多运维工具，比我在 :ref:`debian_init` 中需要安装的应用要少一些。我的实践适当做了调整:

.. literalinclude:: raspberry_pi_os_init/pi_os_devops
   :language: bash
   :caption: 安装运维管理工具
   :emphasize-lines: 19
