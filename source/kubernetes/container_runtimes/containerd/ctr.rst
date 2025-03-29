.. _ctr:

============
ctr
============

.. note::

   ``containerd`` 重造了 :ref:`docker` 的很多工具命令，也包括 ``ctr`` ，默认的基于 GRPC api的命令行工具，用来创建和管理 ``contrainerd`` 容器

   注意，参数 ``-n k8s.io`` 需要紧跟 ``ctr`` 命令，不能位于 ``image`` 等子命令之后

- 检查 ``k8s`` 镜像::

   ctr -n k8s.io images ls

- 下载镜像::

   ctr -n k8s.io images pull <image>

举例，在 :ref:`k8s_fuck_gfw` ，从阿里云下载Google的容器镜像:

.. literalinclude:: ../../deploy/k8s_fuck_gfw/ctr_images_pull
   :language: bash
   :caption: 从阿里云镜像下载gcr.io的镜像

- 为镜像打tag::

   ctr images tag source_image:source_tag target_image:target_tag

举例，在 :ref:`k8s_fuck_gfw` ，将阿里云下载的镜像打上对应的Google gcr.io tag:

.. literalinclude:: ../../deploy/k8s_fuck_gfw/ctr_images_tag
   :language: bash
   :caption: 将阿里云下载gcr.io的镜像打上tag

对于不支持 ``tag`` 子命令的 ``ctr`` 版本，可以变通采用 :ref:`docker_ctr_images`

参考
=======

- `containerd Client CLI <https://github.com/projectatomic/containerd/blob/master/docs/cli.md>`_
- `Why and How to Use containerd From Command Line <https://iximiuz.com/en/posts/containerd-command-line-clients/>`_ 这篇文章非常详尽，解析了 ``ctr`` 的很多案例
