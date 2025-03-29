.. _autossh:

============
autossh
============

:ref:`ssh_tunneling_remote_port_forwarding` 可以让我能够将家里的 :ref:`pi_cluster` 提供的服务共享到互联网上，以便我能 :ref:`mobile_work` 。但是，个人家用网络也可能存在短暂异常或者家用电脑断电重启，那么怎么能够自动完成网络连接?

`autossh开源项目 <https://www.harding.motd.ca/autossh/>`_ 提供了以下功能:

- autossh启动一个ssh副本并监视它，当ssh进程死掉或者停止传输流量，就会自动重启这个ssh进程。这个构思是参考了 :ref:`rstunnel` ，但是采用 :ref:`clang` 重构
- autossh作者认为它不像 :ref:`rstunnel` 那样容易操作
- 使用端口转发循环(a loop of port forwardings) 或 远程echo服务来监控连接
- 当遇到快速故障(如连接被拒绝)时，会降低连接尝试速率
- 在 OpenBSD、Linux、Solaris、Mac OS X、Cygwin 和 AIX 上编译和测试

参考
=======

- `autossh开源项目 <https://www.harding.motd.ca/autossh/>`_
