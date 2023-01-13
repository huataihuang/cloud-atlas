.. _containerd_proxy:

======================
containerd代理
======================

由于GFW影响，很多镜像下载都可能出现问题，导致部署非常麻烦。例如在 :ref:`stable_diffusion_on_k8s` 始终出现镜像下载错误。由于部署的 :ref:`z-k8s` 采用了 ``containerd`` ，虽然 :ref:`nerdctl` 可以通过环境变量配置代理，但是对于远程服务器上的 ``containerd`` 也需要通过以下方法配置代理:

- 修改 ``containerd`` 的 :ref:`systemd` 启动服务配置 ``/usr/local/lib/systemd/system/containerd.service`` :

.. literalinclude:: containerd_proxy/containerd.service
   :language: bash
   :caption: 修订 /usr/local/lib/systemd/system/containerd.service 添加代理配置环境变量
   :emphasize-lines: 3,4

- 重启 ``containerd`` 服务::

   systemctl daemon-reload
   systemctl restart containerd

参考
======

- `Can containerd set a http proxy to download image? #1990 <https://github.com/containerd/containerd/issues/1990>`_
- `Dragonfly Http Proxy mode <https://d7y.io/docs/setup/runtime/containerd/proxy/>`_
