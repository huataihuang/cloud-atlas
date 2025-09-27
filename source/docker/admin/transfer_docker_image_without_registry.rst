.. _transfer_docker_image_without_registry:

===================================
无需Docker Registry传输Docker镜像
===================================

我在 :ref:`alpine_dev` 采用Docker运行容器，在部署了合适的运行环境之后，想要把镜像保存下来，用到其他环境中使用。通常我们分发Docker镜像都会使用 :ref:`k8s_deploy_registry` 。但是，对于个人偶尔使用的私有镜像，也许并不想这么折腾(不论是推送到公共镜像服务器还是自建镜像服务器)。此时，可以使用Docker内置的镜像输出和加载功能。

- 首先对运行的容器进行镜像保存:

.. literalinclude:: transfer_docker_image_without_registry/docker_commit
   :caption: ``docker commit`` 对运行的容器进行镜像保存

- 然后将Docker镜像保存为一个tar文件:

.. literalinclude:: transfer_docker_image_without_registry/docker_save
   :caption: ``docker save`` 将镜像保存为tar文件

- 将输出的镜像文件scp到目标主机上

- 在目标主机上执行以下命令加载自己制作的镜像:

.. literalinclude:: transfer_docker_image_without_registry/docker_load
   :caption: 在目标主机上执行 ``docker load`` 将镜像tar文件加载到docker系统中作为镜像

- 然后就可以直接使用这个镜像用于后续工作了，例如运行容器:

.. literalinclude:: ../../container/colima/images/debian_tini_image/dev/run_acloud-dev_container
   :language: bash
   :caption: 运行 ``acloud-dev`` 容器

.. note::

   已验证: ``docker`` 的 ``save`` 和 ``load`` 和 :ref:`nerdctl_load_images_k8s` 完全兼容，可以相互转换

参考
======

- `How to copy Docker images from one host to another without using a repository <https://stackoverflow.com/questions/23935141/how-to-copy-docker-images-from-one-host-to-another-without-using-a-repository>`_
