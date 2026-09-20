.. _podman_proxy:

=========================
Podman 代理设置
=========================

podman进程代理
=================

podman默认是读取系统代理环境变量 ``HTTP_PROXY`` / ``HTTPS_PROXY`` 来完成 ``podman pull`` 的

- 配置 ``~/.profile`` 设置一键代理开关:

.. literalinclude:: podman_proxy/profile
   :caption: 设置代理开关

但是需要注意的是，这个代理设置仅对Host主机上的podman进程有作用，也就是能够解决podman从 ``dockerhub.io`` 下载镜像的问题，但是不能解决 ``podman build`` 命令时容器内部系统的代理问题。

容器内部代理
=============

解决的思路当然也是采用Linux标准的环境变量注入，不过，我也想像Host主机一样提供一个快捷键切换

但是，如果直接将 ``export http_proxy=socks5://127.0.0.1:1082`` 直接作为容器内部的环境变量，就会发现代理访问不了。原因是默认情况下容器内部的回环地址 ``127.0.0.1`` 和 Host主机的 回环地址其实不在同一个名字空间。


