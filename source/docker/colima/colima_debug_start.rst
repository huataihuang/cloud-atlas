.. _colima_debug_start:

==========================
Colima虚拟机启动异常排查
==========================

发现 ``colima ssh`` 失败，检查 ``colima list`` 输出显示虚拟机状态是 ``Broken`` :

.. literalinclude:: colima_debug_start/colima_list_err
   :caption: ``colima list`` 输出显示虚拟机状态是 ``Broken``
   :emphasize-lines: 2

尝试通过前台运行:

.. literalinclude:: colima_startup/colima_foreground
   :caption: 前台运行 ``colima`` 服务

输出报错:

.. literalinclude:: colima_debug_start/colima_foreground_err
   :caption: 前台运行 ``colima`` 服务报错
   :emphasize-lines: 5-6

究竟什么是 ``vz driver is running but host agent is not`` ?

参考 `colima start does not honor default config, but then overwrites it #985 <https://github.com/abiosoft/colima/issues/985>`_ 可能需要执行:

.. literalinclude:: colima_debug_start/fix
   :caption: 修复colima启动
   :emphasize-lines: 1

修复的关键可能是 ``colima stop -f`` 这个命令似乎清理了环境(待后续验证)，目前还没有再次遇到，可能的因素有:

- 最近做了一次macOS系统升级，重启可能是强制没有清理干净环境

参考
=======

- `colima start does not honor default config, but then overwrites it #985 <https://github.com/abiosoft/colima/issues/985>`_
