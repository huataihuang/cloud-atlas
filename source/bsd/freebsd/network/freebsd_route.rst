.. _freebsd_route:

================
FreeBSD设置路由
================

FreeBSD的路由设置方法和 :ref:`linux` 略有不同

- 检查路由:

.. literalinclude:: freebsd_route/netstat
   :caption: 检查路由

输出类似:

.. literalinclude:: freebsd_route/netstat_output
   :caption: 路由输出案例
   :emphasize-lines: 5,6

- 上述没有指定协议类型会同时输出IPv4和IPv6，为了能够区分，可以使用 ``-4`` 参数来只显示IPv4路由

.. literalinclude:: freebsd_route/netstat-4
   :caption: 检查IPv4路由

输出:

.. literalinclude:: freebsd_route/netstat-4_output
   :caption: 检查IPv4路由

- 命令行设置默认路由:

.. literalinclude:: freebsd_route/route_default
   :caption: 设置默认路由

- 命令行删除默认路由:

.. literalinclude:: freebsd_route/route_delete_default
   :caption: 删除默认路由

配置
=======

为保持FreeBSD重启后默认路由，需要配置 ``/etc/rc.conf`` :

.. literalinclude:: freebsd_route/rc.conf
   :caption: 设置 ``/etc/rc.conf`` 默认路由

修订配置文件后，使用如下命令:

.. literalinclude:: freebsd_route/restart_configured_interfaces
   :caption: 重启服务使配置路由生效

参考
======

- `FreeBSD Set a Default Route / Gateway <https://www.cyberciti.biz/faq/freebsd-setup-default-routing-with-route-command/>`_
- `FreeBSD Static Routing Configuration <https://cyberciti.biz/faq/howto-freebsd-configuring-static-routes/>`_
- `FreeBSD Manual Pages: route(8) <https://man.freebsd.org/cgi/man.cgi?route>`_
