.. _gpu_k8s_deploy_fedora-dev-tini:

===========================================
GPU Kubernetes集群部署Fedora开发开发环境
===========================================

在 :ref:`gpu_k8s_arch` 构建完成后，采用 :ref:`kind_deploy_fedora-dev-tini` 相同的镜像 :ref:`fedora_tini_image` 部署一个包含GPU硬件的运行容器，以便进一步实践 :ref:`machine_learning` 。

为了能够实现完整机器学习工作环境(GPU)，采用 :ref:`gpu_k8s_arch` ，在 :ref:`install_nvidia_container_toolkit_for_containerd` ( :ref:`container_runtimes` 支持GPU  )之后，就可以通过 :ref:`nvidia_gpu_operator` 在Kuternetes :ref:`z-k8s` 集群上运行支持GPU的容器。

我采用 :ref:`fedora_tini_image` 来运行一个 :ref:`fedora` 容器，部署在Kubernetes中(不是必须，但是这样比较符合企业模式)

准备工作
===========

- :ref:`k8s_deploy_registry` 为 :ref:`z-k8s` 提供一个内部registry仓库，这样后续部署应用镜像可以避免网络阻塞
- 如果没有部署私有registry仓库，如果 :ref:`container_runtimes` 是 :ref:`containerd` ，也可以采用 :ref:`nerdctl_load_images_k8s`

.. note::

   本文实践由于时间紧迫，所以采用 :ref:`nerdctl_load_images_k8s` (还没来得及完成 :ref:`k8s_deploy_registry` )

构建 ``fedora-dev`` 镜像
-------------------------

.. note::

   我以 :ref:`fedora_tini_image` 的开发镜像运行容器，让后在容器中 :ref:`install_anaconda` ，并最终制作出 ``fedora-dev`` 镜像推送到 :ref:`z-k8s` 

- 采用 :ref:`fedora_tini_image` ，准备如下 ``Dockerfile`` :

.. literalinclude:: ../../docker/images/fedora_tini_image/dev/Dockerfile
   :language: dockerfile
   :caption: 构建包含开发环境的Dockerfile

.. literalinclude:: ../../docker/images/fedora_tini_image/ssh/entrypoint_ssh_cron_bash
   :language: bash
   :caption: ``entrypoint_ssh_cron_bash`` 用于构建镜像中的 ``/entrypoint.sh``

下载 :ref:`docker_tini` 对应于主机架构(x86或 :ref:`arm` )版本，存放为 ``tini`` ；将 :ref:`ssh_key` 公钥文件 ``authorized_keys`` 也存放在当前目录

- 执行镜像构建:

.. literalinclude:: ../../docker/images/fedora_tini_image/dev/build_fedora-dev-tini_image
   :language: bash
   :caption: 构建 ``fedora-dev-tini`` 镜像

- 运行容器:

.. literalinclude:: ../../docker/images/fedora_tini_image/dev/run_fedora-dev-tini_container
   :language: bash
   :caption: 运行 ``fedora-dev-tini`` 容器

- :ref:`install_anaconda` 完成 :ref:`machine_learning` 工作环境部署:

.. literalinclude:: ../../machine_learning/startup/install_anaconda/anaconda.sh
   :language: bash
   :caption: 下载和运行Anaconda Installe


