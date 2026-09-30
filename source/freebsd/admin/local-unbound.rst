.. _local-unbound:

===================
local-unbound服务
===================

``local-unbound`` 是一个FreeBSD系统内置的 **轻量级本地DNS缓存/递归解析服务** ，是基于著名开源DNS服务器Unbound裁剪并集成到FreeBSD核心库中的。 ``local-unbound`` 主要作用是在本地节点缓存经常查询的域名IP，降低网络延迟并减少对上游DNS服务器的请求频率。

在 :ref:`upgrade_freebsd_pkgbase` 执行 Base系统更新时提示:

.. literalinclude:: freebsd_pkgbase/upgrade_base_output
   :caption: 更新base系统提示信息

此时需要检查系统是否使用了 ``local-unbound`` 服务，即检查 ``/etc/rc.conf`` 中是否开启该服务:

.. literalinclude:: local-unbound/rc.conf
   :caption: ``/etc/rc.conf`` 配置启动 ``local-unbound``

当系统启用了 ``local-unbound`` 之后，该服务会将系统全局DNS解析地址 ``/etc/resolv.conf`` 自动指向 ``127.0.0.1`` (本机)，再由 ``local-unbound`` 负责向上游(如 DHCP 获取到的 DNS、或手动指定的 8.8.8.8 / 114.114.114.114)进行递归查询。


参考
======

- gemini

