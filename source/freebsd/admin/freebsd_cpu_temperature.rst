.. _freebsd_cpu_temperature:

==========================
FreeBSD CPU温度检测
==========================

我在FreeBSD系统中尝试通过PCI Passthrough方式在 :ref:`bhyve` Linux虚拟机中使用 :ref:`tesla_p4` ，但是改装风扇散热不确定是否能够满足要求。所以，我尝试监控主机的温度和散热风扇的转速，以及调整风扇转速的方法。

这里汇总FreeBSD的CPU温度检测方法，并一一实践来对比最佳方案。

.. note::

   :ref:`check_server_temp` 记录了在Linux平台监控服务器温度的方法，可以对比

   我还在摸索如何控制AMI BIOS设置风扇转速的命令方法

``coretemp`` 模块
========================

FreeBSD内核驱动模块 ``coretemp`` 加载以后就能够通过 ``sysctl`` 获取CPU温度，方法如下:

- 加载CPU temp模块，需要针对Intel / AMD 处理器分别加载不同模块:

.. literalinclude:: freebsd_cpu_temperature/kldload_coretemp
   :caption: 加载CPU temp模块

- 通过 ``sysctl`` 获取CPU问题:

.. literalinclude:: freebsd_cpu_temperature/sysctl_temp
   :caption: 获取CPU温度

在我的 :ref:`xeon_e-2274g` 有如下输出案例:

.. literalinclude:: freebsd_cpu_temperature/sysctl_temp_output
   :caption: 获取CPU温度

- 如果要在启动时加载temp模块，则修订 ``/boot/loader.conf`` 添加:

.. literalinclude:: freebsd_cpu_temperature/coretemp_load
   :caption: 设置启动时加载temp内核模块

:ref:`ipmitool`
===================

如果硬件支持 ``ipmitool`` ，则通过 ``sensor`` 子命令可以获得服务器的传感器问题:

.. literalinclude:: freebsd_cpu_temperature/ipmitool_sensor
   :caption: 通过 sensor 获取服务器温度

不过，如果主机没有支持IPMI硬件，则会出现报错:

.. literalinclude:: freebsd_cpu_temperature/ipmitool_sensor_err
   :caption: 通过 sensor 获取服务器温度报错，原因是没有IPMI支持

.. note::

   如果服务器是Supermicro硬件， ``bsdhwmon`` 工具可以提供硬件传感器监控。参见 `GitHub: koitsu/bsdhwmon <https://github.com/koitsu/bsdhwmon>`_ (该工具在FreeBSD发行版提供，可以通过 ``pkg`` 安装)

参考
======

- `FreeBSD find CPU (processor) temperature command <https://www.cyberciti.biz/faq/freebsd-determine-processor-cpu-temperature-command/>`_
- `How to talk to a local IPMI under FreeBSD 14 <https://utcc.utoronto.ca/~cks/space/blog/unix/FreeBSDLocalIPMI>`_
