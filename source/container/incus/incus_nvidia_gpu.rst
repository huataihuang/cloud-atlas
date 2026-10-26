.. _incus_nvidia_gpu:

==========================
Incus容器中使用NVIDIA GPU
==========================

我在 :ref:`incus_startup` 完成 :ref:`debian` 12 容器 ``debian12-dev`` ，进一步部署 :ref:`tesla_a2` 的容器来模拟 :ref:`kubernetes` 的node节点，以模拟实现大规模GPU集群。

.. note::

   之所以选择 ``Incus`` 的LXC容器系统来模拟Kubernetes集群，是因为Incus提供你了完整的 :ref:`systemd` 来拉起和管理 :ref:`kubernetes` / :ref:`k3s` 集群，能够更接近(模拟)生产环境的物理机/虚拟机架构:

   - :ref:`systemd` 提供了真机的一致性
   - k8s/k3s 在Debian 12系统容纳起中启动时，和真实服务器一样通过 :ref:`systemd` 注册服务、管理 :ref:`containerd` 和网络插件，模拟更为真实
   - 比 :ref:`kvm` 虚拟化开销更小，能够在一台主机上启动多个节点来模拟高可用集群

Host主机准备
==============

:ref:`install_nvidia_linux_driver_ubuntu`
---------------------------------------------

**物理主机** 需要安装 NVIDIA driver:

.. literalinclude:: ../..//machine_learning/hardware/nvidia_gpu/install_nvidia_linux_driver_ubuntu/install_595
   :caption: 安装 ``nvidia-driver-595-server-open`` 驱动

:ref:`nvidia_container_toolkit`
-----------------------------------

**物理主机** 需要安装 NVIDIA Container Toolkit:

- 安装必要的工具:

.. literalinclude:: ../../docker/gpu/nvidia_container_toolkit/prepare
   :caption: 安装工具

- 配置仓库:

.. literalinclude:: ../../docker/gpu/nvidia_container_toolkit/repo
   :caption: 仓库


- 更新仓库:

.. literalinclude:: ../../docker/gpu/nvidia_container_toolkit/update_repo
   :caption: 更新仓库

- 安装 ``NVIDIA Container Toolkit`` 软件包:

.. literalinclude:: ../../docker/gpu/nvidia_container_toolkit/install
   :caption: 安装 ``NVIDIA Container Toolkit``

部署使用GPU的LXC容器
========================

在宿主机安装完 ``nvidia-container-toolkit`` 后，就可以通过 Incus 启动带 GPU 的容器

- 首先检查系统中NVIDIA显卡，在Host主机执行 ``nvidia-smi`` 命令可以看到我的主机上安装了3块 :ref:`tesla_a2` :

.. literalinclude:: ../../machine_learning/hardware/nvidia_gpu/install_nvidia_linux_driver_ubuntu/nvidia-smi_output_a2
   :caption: 在Host主机上检查 ``nvidia-smi`` 输出(pci)
   :emphasize-lines: 10,14,18

- 创建LXC容器，注意创建时使用参数 ``-c nvidia.runtime=true`` :

.. literalinclude:: incus_nvidia_gpu/launch_gpu
   :caption: 启动一个开启 ``nvidia.runtime`` 的容器

- 将第一块GPU添加到容器:

.. literalinclude:: incus_nvidia_gpu/add_gpu
   :caption: 在线将GPU添加到运行的容器中

- 这个GPU设备添加是立即生效的，所以马上可以在容器内部执行 ``nvidia-smi`` 命令:

.. literalinclude:: incus_nvidia_gpu/nvidia-smi
   :caption: 容器内部执行 ``nvidia-smi``

见证奇迹的时刻，现在就可以在容器内部看到这块添加的GPU设备

.. literalinclude:: incus_nvidia_gpu/nvidia-smi_output
   :caption: 容器内部执行 ``nvidia-smi`` 看到添加的GPU
   :emphasize-lines: 9

- 并且也可以将Host主机的多块GPU加入到这个容器中:

.. literalinclude:: incus_nvidia_gpu/add_gpu_again
   :caption: 添加多块GPU

- 再次执行容器中的 ``nvidia-smi``

.. literalinclude:: incus_nvidia_gpu/nvidia-smi
   :caption: 容器内部执行 ``nvidia-smi``

则可以看到容器中现在就有3块Tesla A2 GPU

.. literalinclude:: incus_nvidia_gpu/nvidia-smi_output_again
   :caption: 容器内部执行 ``nvidia-smi`` 看到添加的 **3块** GPU
   :emphasize-lines: 9,13,17

