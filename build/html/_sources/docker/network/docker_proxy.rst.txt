.. _docker_proxy:

====================
配置Docker使用代理
====================

如果你也苦于GFW的阻塞，无法正常更新软件，并且在docker需要pull images时候发现无法下载Docker镜像，则可以部署 :ref:`squid` 的 :ref:`squid_socks_peer` 来实现代理翻墙。这里介绍如何配置docker客户端，以便能够通过代理加速镜像下载。

这个方法也使得容器内部能够不需要单独配置代理，直接通过代理服务器上网。

Docker客户端的Proxy
======================

Docker客户端支持使用代理服务器，主要有两种方式配置：

- 从Docker 17.07和更高版本，可以配置 Docker可短自动传递代理信息给容器
- Docker 17.06或低版本，则需要在容器中设置相应的环境变量

配置Docker客户端
-------------------

- 在Docker客户端，创建或配置 ``~/.docker/config.json`` 设置以下json格式配置::

   {
    "proxies":
    {
      "default":
      {
        "httpProxy": "http://127.0.0.1:3001",
        "httpsProxy": "http://127.0.0.1:3001",
        "noProxy": "*.test.example.com,.example2.com"
      }
    }
   }

- 然后创建的新容器，在容器中的环境变量会自动设置代理

Docker客户端环境变量
--------------------

可以在 dockerfile 中配置::

   ENV HTTP_PROXY "http://127.0.0.1:3001"
   ENV HTTP_PROXY "http://127.0.0.1:3001"
   ENV FTP_PROXY "ftp://127.0.0.1:3001"
   ENV NO_PROXY "*.test.example.com,.example2.com"

也可以在运行命令行使用参数::

   --env HTTP_PROXY="http://127.0.0.1:3001"
   --env HTTPS_PROXY="https://127.0.0.1:3001"
   --env FTP_PROXY="ftp://127.0.0.1:3001"
   --env NO_PROXY="*.test.example.com,.example2.com"

Docker服务器Proxy
===================

systemd配置Docker服务器Proxy
--------------------------------

.. warning::

   配置Docker服务器使用Proxy是成功的，但是访问Docker Hub证书存在问题，见后文参考官方设置。

对于主机上的dockerd服务，在下载镜像等工作使用代理，则需要配置服务的环境变量。

- 创建 ``/etc/systemd/system/docker.service.d/http-proxy.conf`` 配置文件::

   [Service]
   Environment="HTTP_PROXY=http://user01:password@10.10.10.10:8080/"
   Environment="HTTPS_PROXY=https://user01:password@10.10.10.10:8080/"
   Environment="NO_PROXY= hostname.example.com,172.10.10.10"

- 然后重新加载配置并重启服务::

   systemctl daemon-reload
   systemctl restart docker

- 然后检查加载的配置::

   systemctl show docker --property Environment

可以看到输出::

   Environment=GOTRACEBACK=crash HTTP_PROXY=http://10.10.10.10:8080/ HTTPS_PROXY=http://10.10.10.10:8080/ NO_PROXY= hostname.example.com,172.10.10.10

Ubuntu配置Docker服务器Proxy
-----------------------------

.. note::

   暂时没有环境验证，本段落待实践。

在Ubuntu上配置Docker服务器Proxy非常简单，只需要编辑 ``/etc/default/docker`` ::

   # If you need Docker to use an HTTP proxy, it can also be specified here.
   export http_proxy="http://127.0.0.1:3128/"

按照上述配置完成后重启::

   sudo systemctl restart docker

Docker官方解决方案
--------------------

参考 Docker官方文档 `Running a Docker daemon behind an HTTPS_PROXY <https://docs.docker.com/engine/reference/commandline/dockerd/#running-a-docker-daemon-behind-an-https_proxy>`_ 配置局域网在https代理后使用docker服务:

- 安装 ``ca-certificates`` 软件包

- 在 ``/etc/pki/tls/certs/ca-bundle.crt`` 中添加代理服务器证书

- 启动 Docker 时使用参数 ``HTTPS_PROXY=http://username:password@proxy:port/``

.. note::

   这也是前述配置代理后出现证书错误的解决方法：需要在服务器上添加代理服务器证书

参考
======

- `Configure Docker to use a proxy server <https://docs.docker.com/network/proxy/>`_
- `How to configure docker to use proxy <https://www.thegeekdiary.com/how-to-configure-docker-to-use-proxy/>`_
- `Configure Docker to use a proxy server <https://docs.docker.com/network/proxy/>`_
- Docker官方文档 `Running a Docker daemon behind an HTTPS_PROXY <https://docs.docker.com/engine/reference/commandline/dockerd/#running-a-docker-daemon-behind-an-https_proxy>`_
