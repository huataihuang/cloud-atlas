.. _cockpit_port_address:

=======================
Cockpit监听端口和地址
=======================

Cockpit的 ``cockpit-ws`` 组件默认配置的端口是 ``9090`` ，这个端口是和 :ref:`prometheus` 默认端口是重合的，这会导致 :ref:`prometheus_startup` 部署在主机上的 Prometheus 启动失败。

比较简单的方法是调整 ``cockpit`` 的TCP监听端口

- 修改 ``/etc/systemd/system/cockpit.socket.d/listen.conf`` (在 :ref:`ubuntu_linux` 发行版默认你配置 ``/etc/systemd/system/sockets.target.wants/cockpit.socket`` )::

   [Socket]
   ListenStream=
   ListenStream=9091

这里的 ``ListenStream=`` 是有意配置的，因为 :ref:`systemd` 允许多端口监听，所以这里配置一个空的配置表示关闭掉原始配置默认的 ``9090`` 端口

- 重启服务::

   sudo systemctl daemon-reload
   sudo systemctl restart cockpit.socket

参考
======

- `Cockpit docs: TCP Port and Address <https://cockpit-project.org/guide/latest/listen>`_
