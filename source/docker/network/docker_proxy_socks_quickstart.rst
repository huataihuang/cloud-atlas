.. _docker_proxy_socks_quickstart:

================================
Docker 代理快速起步(Socks版本)
================================

.. note::

   本文基于 :ref:`docker_proxy_quickstart` 修订为采用 :ref:`ssh_tunneling_dynamic_port_forwarding` 的socks代理模式, 实现简单易用的Docker :ref:`across_the_great_wall`

概述
=======

之前在 :ref:`docker_proxy_quickstart` 实践中我采用了 :ref:`ssh_tunneling` 将本地回环地址端口 ``3128`` 映射到墙外的VPS上 :ref:`squid` 或 :ref:`privoxy` 服务端口 ``3128`` ，这个架构基于标准的HTTP代理，功能更完备(在Squid服务器端可以实现复杂的过滤和缓存)，但是毕竟多了服务器端部署，所以对于简单的 Docker :ref:`across_the_great_wall` 有点过于复杂了。

所以，我在这里想用更为简单的部署来完成:

- 只需要租用一个配置了 :ref:`ssh` 的海外VPS
- 本地ssh客户端用一条命令就能够建立起 :ref:`ssh_tunneling_dynamic_port_forwarding` 的socks代理，为整个docker提供代理

Host主机配置 :ref:`ssh_tunneling_dynamic_port_forwarding`
=============================================================

- 设置

.. literalinclude:: ../../infra_service/ssh/ssh_tunneling_dynamic_port_forwarding/ssh_config
   :caption: 配置 ``~/.ssh/config`` 设置动态端口转发
   :emphasize-lines: 12

然后执行 ``ssh MyProxy`` 建立加密动态端口转发通道

设置docker的 :ref:`systemd` 配置
====================================

- 为Docker服务创建配置目录:

.. literalinclude:: docker_proxy_socks_quickstart/system_dir
   :caption: 创建Docker服务配置目录

- 在该配置目录下创建名为 ``http-proxy.conf`` 文件:

.. literalinclude:: docker_proxy_socks_quickstart/http-proxy.conf
   :caption: 创建 ``http-proxy.conf`` 配置

.. note::

   这里使用 ``socks5h`` 协议可以强制代理服务器解析域名，如果对于某些docker版本不兼容，可以改为 ``socks5``

- 然后重启 docker 服务:

.. literalinclude:: docker_proxy_socks_quickstart/restart_docker
   :caption: 重启docker

- 验证配置:

.. literalinclude:: docker_proxy_socks_quickstart/docker_info
   :caption: 验证docker代理配置

输出类似

.. literalinclude:: docker_proxy_socks_quickstart/docker_info_output
   :caption: 验证docker代理配置输出

容器内代理
==============

以上对docker的配置仅针对拉去镜像，对于启动的容器中的操作系统如果也要使用代理，则在运行时传递参数:

.. literalinclude:: docker_proxy_socks_quickstart/docker_run_proxy
   :caption: docker运行时向容器中的操作系统注入代理配置

