.. _sysrq:

==================================
Linux "魔力" 系统请求组合键 SysRq
==================================

所谓 ``"魔力" 系统请求组合键`` 是指不论内核在做什么，都会响应这个组合键 ``magical key combo`` (除非内核完全锁死)。我们通常会使用 ``magic SysRq key`` 来实现内核级的调试信息输出。

如何激活magic SysRq key
========================

首先在内核配置上，需要配置 ``CONFIG_MAGIC_SYSRQ=Y`` ，这样编译出来的支持SysRq的内核，启动后会提供一个 ``/proc/sys/kernel/sysrq`` 控制功能，允许使用SysRq键。

其次，在内核 ``CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE`` 配置符号，默认设置是 ``1`` 

============ ======== ==================================
SysRq配置值   16进制    说明
0            0x0      关闭所有sysrq功能
1            0x1      激活所有sysrq功能
2            0x2      激活控制台日志级别控制
4            0x4      激活键盘控制(SAK, unraw)
8            0x8      激活进程的debug dump
16           0x10     激活sync命令
32           0x20     激活remount read-only
64           0x40     激活进程信号(term, kill, oom-kill)
128          0x80     允许重启/关机
256          0x100    允许所有实时任务配置nice
============ ======== ==================================

- 执行启用sysrq所有功能::

   echo 1 > /proc/sys/kernel/sysrq

- 在完成sysrq的指令之后(见下文)，可能需要关闭sysrq功能，则可以输入0::

   echo 0 > /proc/sys/kernel/sysrq

使用SysRq
===========



参考
=====

- `Linux Magic System Request Key Hacks <https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html>`_
