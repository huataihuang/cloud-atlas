.. _rstunnel:

==================
RSTunnel
==================

`GitHub: JayGoldberg/RSTunnel <https://github.com/JayGoldberg/RSTunnel>`_ 是一个可靠的SSH Tunnel的持续维护，但是它不需要 :ref:`autossh` 就可以工作。这个 ``RSTunnel`` (可靠 SSH Tunnel)是一组 **纯shell脚本** (兼容 ``/bin/sh`` )用于维护从客户端到服务器的安全隧道。

:ref:`autossh` 的麻烦之处是它是 :ref:`clang` 程序，需要为不同的架构平台编译，而获取交叉编译工具链并非易事，所以最好依赖大多数操作系统内置的二进制文件。 ``RSTunnel`` 目标是只使用 :ref:`shell` ，而且兼容最简单的 ``ash`` ，以及能够兼容像dropbear SSH这种不常用的客户端。

- 简单查看一下 ``rstunnel`` 脚本，就可以看到关键的一句检查SSH Tunnel是否正常工作的语句:

.. literalinclude:: rstunnel/nc
   :caption: 通过 ``nc`` 工具检查SSH Tunnel是否工作
   :emphasize-lines: 2,4

脚本写得很精简，阅读可以理解原理以及辅助逻辑

.. _ctunnel:

CTunnel
=========

.. note::

   我比较习惯使用SSH config来控制SSH，所以我fork了RSTunnel改写了一个 `CTunnel(持久化Tunnel) <https://github.com/huataihuang/CTunnel>`_ (还比较粗糙，待改进)

- 随脚本提供了一个 ``install`` 工具，用于通过交互方式完成安装，实际上就是生成一个 ``rstunnel.conf``

- 运行依赖 ``nc`` 命令，是通过 ``netcat`` 工具包提供，所以需要确保安装:

.. literalinclude:: rstunnel/install_netcat
   :caption: 安装 ``netcat`` 来获得 ``nc``

参考
=======

- `GitHub: JayGoldberg/RSTunnel <https://github.com/JayGoldberg/RSTunnel>`_
