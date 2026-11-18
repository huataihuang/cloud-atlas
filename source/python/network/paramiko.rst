.. _paramiko:

========================
Python SSH模块paramiko
========================

``paramiko`` 模块是SSHv2协议的纯Python实现，用于连接到远程服务器，执行shell命令以及安全传输文件。它提供了客户端和服务器功能并且是更高层工具Fabric的底层引擎。

- 安装 ``paramiko`` :

.. literalinclude:: paramiko/install
   :caption: 安装 ``paramiko``

基本使用
=============

.. literalinclude:: paramiko/simple_ssh.py
   :language: python
   :caption: 简单ssh连接

看起来没有问题，但是运行时会有报错:

.. literalinclude:: paramiko/simple_ssh_error
   :caption: NoValidConnectionsError报错
   :emphasize-lines: 2

那么什么是 ``NoValidConnectionsError`` ?

- 使用 ``nc`` 工具检查端口连接:

.. literalinclude:: paramiko/nc
   :caption: 测试网络端口

输出完全正常:

.. literalinclude:: paramiko/nc_output
   :caption: 测试网络端口

- 使用python原生socket测试，绕过paramiko

.. literalinclude:: paramiko/test.py
   :caption: 原生ssh测试

.. note::

   初步找到原因了，我发现在我的 :ref:`tmux` 环境中使用这段python代码存在问题，如果是普通终端环境没有问题。

   怀疑是本地开启了VPN导致的，虽然关闭了VPN，但是tmux可能是有影响？ **以后再排查**

参考
=======

- `Paramiko- How to SSH and transfer files with python <https://medium.com/@keagileageek/paramiko-how-to-ssh-and-file-transfers-with-python-75766179de73>`_
