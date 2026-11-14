.. _agetty_issue:

======================================
``agetty`` 处理 ``/etc/issue`` Tips
======================================

引子
=======

我的台式机安装了无线网卡，每次重启系统可能会获得不同的IP地址。这让我远程ssh访问有点困扰，想知道IP地址是多少。我记得以前使用FreeBSD能够在启动的终端上打印当前主机分配的地址。那么在Linux上是如何实现的呢？

当然，如果安装了 :ref:`cockpit` 服务启动时会提示你当前主机受cockpit监控管理，也就显示了IP。不过，我想应该有更简单的方法。

原理
=======

gemini提示是通过 ``/etc/issue`` 实现的终端提示信息，结合一个简单的自定义脚本或系统服务来实现。

``agetty`` 内置占位符
=======================

既然 ``/etc/issue`` 是 ``agetty`` 所使用的显示在终端登录上的文字，我查看了一下帮助文档，发现原来 ``agetty`` 程序已经考虑到这些情况，内置了一些占位符号来实现:

- ``\4`` : 第一个激活的IPv4地址
- ``\4{interface}`` : 指定接口上的IPv4地址，例如 ``\4{eth0}`` 或 ``\4{enp3s0}``
- ``\6`` : IPv6地址
- ``\n`` : 主机名
- ``\l`` : 登录终端名，例如 ``tty3``

所以，实际上我通过以下的 ``/etc/issue`` 配置来实现两个网卡上的IP地址显示:

.. literalinclude:: agetty_issue/issue
   :caption: ``/etc/issue`` 配置显示主机IP地址

systemd服务脚本(参考)
=======================

.. note::

   我没有使用这段方法，因为有更简单的使用 ``agetty`` 内置占位符功能来实现，见上文

- ``update-ip-issue.sh`` 用于寻找IP地址

.. literalinclude:: agetty_issue/update-ip-issue.sh
   :language: bash
   :caption: 寻找IP地址

注意要将脚本设置为可执行 ``sudo chmod +x /usr/local/bin/update-ip-issue.sh``

- 新建服务配置文件 ``/etc/systemd/system/update-ip-prompt.service``

.. literalinclude:: agetty_issue/update-ip-prompt.service
   :caption: 配置 ``/etc/systemd/system/update-ip-prompt.service``

- 加载服务:

.. literalinclude:: agetty_issue/systemd
   :caption: 启动服务
