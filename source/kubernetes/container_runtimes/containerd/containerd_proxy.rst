.. _containerd_proxy:

======================
containerd代理
======================

由于GFW影响，很多镜像下载都可能出现问题，导致部署非常麻烦。例如在 :ref:`stable_diffusion_on_k8s` 始终出现镜像下载错误。由于部署的 :ref:`z-k8s` 采用了 ``containerd`` ，虽然 :ref:`nerdctl` 可以通过环境变量配置代理，但是对于远程服务器上的 ``containerd`` 也需要通过以下方法配置代理:

.. _containerd_client_proxy:

containerd客户端代理
=======================

``containerd`` 客户端代理用于向容器内部注入 proxy 配置，以便容器内部操作系统能够通过代理下载。对于Kubernetes的pod，可以通过 :ref:`config_pod_by_configmap` 向容器内部注入环境变量

:ref:`docker_proxy` 支持客户端代理配置，也就是 ``$DOCKER_CONFIG/config.json`` 或者 ``$DOCKER_CONFIG/config.json`` 配置代理，可以直接注入到容器内部作为代理配置环境变量。

.. note::

   :strike:`我还没有找到如何在 containerd 客户端(容器内部)注入代理的方法...` 这方面还是 :ref:`docker_proxy` 更为成熟

   对于containerd客户端，也就是容器内部，由于都是配置Kubernetes使用，所以可以直接使用Kubernetes的环境变量注入来实现( `How to Make the Most of Kubernetes Environment Variables <https://release.com/blog/kubernetes-environment-variables>`_ ):

   - ``env:`` 设置
   - secret
   - :ref:`config_pod_by_configmap`

.. _containerd_server_proxy:

containerd服务端代理
=======================

``containerd`` 服务端代理用于管理物理主机上 ``containerd`` 的镜像下载代理

- 可以直接修改 ``containerd`` 的 :ref:`systemd` 启动服务配置 ``/usr/local/lib/systemd/system/containerd.service`` :

.. literalinclude:: containerd_proxy/containerd.service
   :language: bash
   :caption: 修订 /usr/local/lib/systemd/system/containerd.service 添加代理配置环境变量
   :emphasize-lines: 3,4

- 不过，更好的是为 ``containerd`` 添加一个独立的配置 ``/etc/systemd/system/containerd.service.d/http-proxy.conf`` :\

.. literalinclude:: containerd_proxy/create_http_proxy_conf_for_containerd
   :language: bash
   :caption: 生成 /etc/systemd/system/containerd.service.d/http-proxy.conf 为containerd添加代理配置
   :emphasize-lines: 7-9

那么环境变量该在哪里配置呢？按照约定俗成，应该在 ``/etc/environemt`` 设置:

.. literalinclude:: containerd_proxy/environment_proxy
   :language: bash
   :caption: 在 /etc/environment 中添加代理配置

- 重新登陆系统(确保 ``/etc/environment`` 环境变量生效)重启 ``containerd`` 服务::

   systemctl daemon-reload
   systemctl restart containerd

参考
======

- `Can containerd set a http proxy to download image? #1991 <https://github.com/containerd/containerd/issues/1990>`_
- `Dragonfly Http Proxy mode <https://d7y.io/docs/setup/runtime/containerd/proxy/>`_
- `Containerd is not working behind a proxy #688 <https://github.com/kubernetes-sigs/kind/issues/688>`_
