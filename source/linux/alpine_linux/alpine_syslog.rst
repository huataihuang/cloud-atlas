.. _alpine_syslog:

===========================
Alpine Linux syslog
===========================

Alpine Linux内置了一个极小化 ``syslogd`` 服务，即通过默认的 ``BusyBox`` 来实现系统日志:

- 轻量级: 资源使用最小化，满足Alpine容器的精简目标
- 简单: 提供基本的日志功能，包括日志写入文件和日志轮转
- 默认: 不需要安装任何第三方软件包，保持系统最小化

配置
=======

``/etc/conf.d/syslog`` 配置文件用于调整 ``syslogd`` 运行选项，所有的运行选项可以通过 ``syslogd --help`` 查看，实际上选项也不多:

.. literalinclude:: alpine_syslog/syslogd
   :caption: ``syslogd`` 的运行选项
   :emphasize-lines: 9,10,20

需要注意:

- 默认监听在服务器的 ``UDP`` 端口 ``514`` ，这是一个私有端口(低于1024)

:strike:`当在podman rootless容器中运行，这个端口可能会不能监听会产生错误` 下面这个错误是因为没有使用 ``sudo`` 来启动 ``syslogd`` 导致的，实践发现 alpine linux 的 syslogd 没有绑定 514 端口权限问题

.. literalinclude:: alpine_syslog/bind_error
   :caption: 在 ``podman`` rootless 容器中运行，由于UDP 514端口无法绑定报错

解决的方法是在 ``/etc/conf.d/syslog`` 中配置:

.. literalinclude:: alpine_syslog/conf.d_syslog
   :caption: ``/etc/conf.d/syslog`` 监听高端口 ``10514``

这样启动 ``syslogd`` 监听在本地 ``10514`` 端口

然后在运行 ``podman run`` 时候设置端口映射，将Host端口514映射到10514:

.. literalinclude:: alpine_syslog/portmap_syslogd
   :caption: podman运行时映射Host端口514映射到10514

.. warning::

   上述podman rootless运行syslogd的方法我没有实践，我主要目标是debug排查 podman rootless 运行 sshd服务(已解决，见 :ref:`alpine-dev_dockerfile` )，已经花费太多时间，暂时没有精力折腾了

参考
=======

- `Alpine Linux Wiki: Syslog <https://wiki.alpinelinux.org/wiki/Syslog>`_
