.. _config_docker_deamon_rancher_desktop:

=======================================
配置Rancher Desktop的Docker Daemon
=======================================

.. note::

   `Configuring Docker Daemon in Rancher Desktop: A Complete Guide <https://support.tools/configure-docker-daemon-rancher-desktop/>`_ 提供了通过修改Host主机 ``~/.rancher-desktop/lima/_config/docker/daemon.json`` 来调整 ``Rancher Desktop`` Lima 虚拟机的 ``docker daemon`` 配置方法。我这里实践时采用了直接修改虚拟机内部配置，所以原文方法记录备参考。

   原文提供了一些 :ref:`docker` 配置调整的参数设置，也可以参考(我未实践)

.. _rancher_desktop_docker_daemon_proxy:

配置Rancher Desktop虚拟机Docker服务代理
==========================================

在墙内使用 :ref:`docker` 最大的问题是GFW屏蔽了docker registry，这导致很多公共镜像无法下载。在使用Rancher Desktop的时候，特别是需要下载 :ref:`alpine_docker_image` 时，遇到报错:

.. literalinclude:: config_docker_deamon_rancher_desktop/registry_fail

解决方法是调整 :ref:`docker` 代理，这里首先需要配置的是服务器端代理 ``docker daemon`` 

由于是使用 :ref:`rancher_desktop` 包装了 :ref:`lima` 虚拟化，所以我采用了直接调整 ``lima`` 虚拟机内部的 ``/etc/docker/daemon.json`` :

.. literalinclude:: config_docker_deamon_rancher_desktop/daemon.json
   :caption: 配置 ``lima`` 虚拟机内部 ``/etc/docker/daemon.json``
   :emphasize-lines: 5-9

.. note::

   另一个配置方法是在Host主机上配置 ``~/.rancher-desktop/lima/_config/docker/daemon.json`` ，让 ``Rancher Desktop`` 启动lima虚拟机的时候自动复制进去。不过，我没有实践，请参考原文 `Configuring Docker Daemon in Rancher Desktop: A Complete Guide <https://support.tools/configure-docker-daemon-rancher-desktop/>`_

这里解决了服务端dockerd通过代理防伪registry之后，我又遇到另外一个报错:

.. literalinclude:: config_docker_deamon_rancher_desktop/proxyconnect_tls_handshake_fail
   :caption: 通过代理访问registry报告TLS握手错误
   :emphasize-lines: 14

乌龙了，原来是我配置 ``daemon.json`` 错误，我的 :ref:`squid` 代理服务是 HTTP 方式，所以设置 docker daemon 时候不能设置 ``"https-proxy": "https://192.168.1.20:3128"`` ，而应该是 ``"https-proxy": "http://192.168.1.20:3128"``

.. _rancher_desktop_docker_client_proxy:

配置Rancher Desktop虚拟机Docker客户端代理
==========================================

需要注意的是，docker下载镜像不仅是 docker dameon 需要配置代理，docker client也需要配置代理，否则会提示另一个访问 auth.docker.io 错误:

.. literalinclude:: config_docker_deamon_rancher_desktop/docker_client_auth_fail
   :caption: docker客户端访问auth服务错误
   :emphasize-lines: 14

解决方法类似服务端，只不过这次是配置docker客户端 ``~/.docker/config.json`` :

.. literalinclude:: config_docker_deamon_rancher_desktop/docker_client_config.json
   :caption: docker客户端配置代理
   :emphasize-lines: 3-9

.. warning::

   非常奇怪，这次在Rancher Desktop上实践遇到了问题，配置上述 ``~/.docker/config.json`` 没有生效，客户端依然是直接访问网络

   所以最终我改成在客户端设置环境变量来解决:

   .. literalinclude:: config_docker_deamon_rancher_desktop/docker_client_env
      :caption: 在客户端设置环境变量配置代理

参考
======

- `Configuring Docker Daemon in Rancher Desktop: A Complete Guide <https://support.tools/configure-docker-daemon-rancher-desktop/>`_
