.. _sysrq:

==================================
Linux "魔力" 系统请求组合键 SysRq
==================================

所谓 ``"魔力" 系统请求组合键`` 是指不论内核在做什么，都会响应这个组合键 ``magical key combo`` (除非内核完全锁死)。我们通常会使用 ``magic SysRq key`` 来实现内核级的调试信息输出。

如何激活magic SysRq key
========================

首先在内核配置上，需要配置 ``CONFIG_MAGIC_SYSRQ=Y`` ，这样编译出来的支持SysRq的内核，启动后会提供一个 ``/proc/sys/kernel/sysrq`` 控制功能，允许使用SysRq键。

其次，在内核 ``CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE`` 配置符号，默认设置是 ``1`` 

.. csv-table:: 激活SysRq功能: 内核配置 ``CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE`` 或者 ``echo <SysRq配置值> > /proc/sys/kernel/sysrq``
   :file: sysrq/sysrq.csv
   :widths: 30,20,50
   :header-rows: 1

- 执行启用sysrq所有功能::

   echo 1 > /proc/sys/kernel/sysrq

- 在完成sysrq的指令之后(见下文)，可能需要关闭sysrq功能，则可以输入0::

   echo 0 > /proc/sys/kernel/sysrq

.. note::

   这里的发送给 ``/proc/sys/kernel/sysrq`` 数字可以写成十进制或者带 ``0x`` 的十六进制，但是在内核配置 ``CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE`` 必须始终以十六进制编写。

   ``/proc/sys/kernel/sysrq`` 的值仅影响通过键盘的调用，而在 ``/proc/sysrq-trigger`` 入口调用是始终允许的(需要系统管理员权限)

使用SysRq
===========

在不同的硬件平台有着不同的组合键出发 ``SysRq`` :

.. note::

   一些键盘没有标记为 ``SysRq`` 的按键，而 ``SysRq`` 键也称为 ``Print Screen`` 键。此外，一些键盘可能无法同时按下 ``SysRq`` 组合键，可以尝试按住 ``Alt`` 键不放，然后顺序按下 ``SysRq`` ，释放 ``SysRq`` 键，再按下 ``<命令键>`` ，然后释放所有键来完成触发。

.. csv-table:: SysRq组合键
   :file: sysrq/sysrq_combo.csv
   :widths: 20,80
   :header-rows: 1

SysRq ``<命令键>``
=====================

.. csv-table:: SysRq命令键
   :file: sysrq/sysrq_cmd.csv
   :widths: 20,80
   :header-rows: 1


参考
=====

- `Linux Magic System Request Key Hacks <https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html>`_
