.. _jetson_xpra:

=================================
通过Xpra使用Jetson Nano图形桌面
=================================

我最初尝试在Jetson Nano上安装Xpra是通过 :ref:`jetson_xpra_build` 实现的，步骤曲折。不过，我在构建 :ref:`edge_cloud_infra` 时，是通过发行版提供的Xpra完成，所以本文记录方法更为通用。

我在 :ref:`edge_jeston` 做了系统精简之后再部署Xpra，如果你喜欢功能大而全的系统，可以忽略我这个精简步骤。

安装Xpra
============

- 使用发行版软件仓库安装Xpra::

   sudo apt install xpra

配置Xpra
===============

证书
-------

注意，此时直接启动xpra服务::

   sudo systemctl start xpa

会发现失败， ``systemctl status xpra`` 显示::

   1月 15 09:56:30 x-k3s-n-0 systemd[1]: Started Xpra System Server.
   1月 15 09:56:32 x-k3s-n-0 xpra[8471]: 2022-01-15 09:56:32,248 wrote pid 8471 to '/run/xpra.pid'
   1月 15 09:56:32 x-k3s-n-0 xpra[8471]: InitException: cannot create SSL socket, check your certificate paths ('/etc/xpra/ssl-cert.pem'): [Errno 2] No such file or directory
   1月 15 09:56:32 x-k3s-n-0 xpra[8471]: xpra initialization error:
   1月 15 09:56:32 x-k3s-n-0 xpra[8471]:  cannot create SSL socket, check your certificate paths ('/etc/xpra/ssl-cert.pem'): [Errno 2] No such file or directory
   1月 15 09:56:32 x-k3s-n-0 systemd[1]: xpra.service: Main process exited, code=exited, status=1/FAILURE
   1月 15 09:56:32 x-k3s-n-0 systemd[1]: xpra.service: Failed with result 'exit-code'.

从报错日志可以看到，没有配置 Xpra 的 ``ssl-cert.pem`` 证书无法启动服务


