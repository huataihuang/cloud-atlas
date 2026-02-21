.. _container_direct_access_amd_gpu:

=====================================
容器直接访问AMD GPU
=====================================

作为开源友好的GPU厂商(也是为了和NVIDIA竞争)，AMD ROCm的设计高度依赖Linux内核的原生机制(例如 ``amdgpu`` 驱动提供的设备文件)，甚至可以不依赖 :ref:`amd_container_toolkit` 就内为容器内部提供GPU的直接访问:

- 从Linux角度来看，GPU就是 ``/dev/kfd`` (计算接口) 和 ``/dev/dri/renderD128`` (渲染接口)
- :ref:`docker` 只需要通过标准的 ``--device`` 参数将上述两个文件映射进容器，容器内的 ``ROCm`` 运行时就能通过这两个接口直接和内核驱动对话
- 

准备工作
=============

- 物理主机需要 :ref:`install_amdgpu` :

.. literalinclude:: ../../machine_learning/rocm/rocm_quickstart/amdgpu_driver_install
   :caption: Ubuntu 24.04 安装 amdgpu 驱动

- 安装完成后检查AMD GPU对应的模块设备:

.. literalinclude:: container_direct_access_amd_gpu/ls_dev
   :caption: 检查 ``amdgpu`` 内核驱动敌营设备

这里显示输出:

.. literalinclude:: container_direct_access_amd_gpu/ls_dev_output
   :caption: 看到4个dri设备是因为我的主机同时安装了2块AMD MI50和2块NVIDIA Tesla A2
   :emphasize-lines: 1,2

.. note::

   我的服务器安装了 2块 :ref:`tesla_a2` 和 2块 :ref:`amd_radeon_instinct_mi50` ，所以在上面的设备检查会看到4个 ``renderD...`` 设备:

   在Linux的Direct Rendering Manager(DRM)子系统中，所有具备渲染能力的GPU都会占用一个 ``renderD`` 编号。要区分设备厂商，可以通过 ``renderD*/device/vendor`` 来区分:

   - AMD的厂商ID是 ``0x1002``
   - NVIDIA的厂商ID是 ``0x10de``

   .. literalinclude:: container_direct_access_amd_gpu/vender
      :caption: 通过vender ID来区分设备厂商

   上述输出可以看到 ``128`` 和 ``129`` 是AMD的设备 MI50，而 ``130`` 和 ``131`` 是NVIDIA的设备 A2

   手工检测的方法比较麻烦，所以安装 :ref:`amd_container_toolkit` 和 :ref:`nvidia_container_toolkit` 就带来了极大的便利，可以直接对各自厂商的GPU设备进行操作而不用编写复杂的检测脚本

需要注意，设备的属主组是 ``render`` ，所以需要将使用者的uid加入到这个组:

.. literalinclude:: container_direct_access_amd_gpu/usermod
   :caption: 将自己的用户帐号加入到 ``render`` 组

- 安装docker:

.. literalinclude:: ../startup/install_docker_linux/ubuntu_install
   :caption: 在Ubuntu中安装发行版提供的docker

为方便管理，将使用者(自己)的uid加入( :ref:`run_docker_without_sudo` ):

.. literalinclude:: ../startup/install_docker_linux/usermod
   :caption: 将当前用户添加到 ``docker`` 用户组

运行
=======

由于Docker容器和host OS共享内核，所以ROCm内核模式驱动( ``amdgrpu-dkms`` )在物理主机上安装完成后，只需要授权Docker容器访问主机AMD GPU就可以在容器中于行ROCm:

.. literalinclude:: container_direct_access_amd_gpu/docker_run
   :caption: 授权docker容器访问host主机的AMD GPU

.. note::

   现在从官方下载运行的Ollama镜像是精简没有包含 ``rocminfo`` 等维护工具

验证
=======

``rocminfo`` 能够提供HSA系统属性以及agents的信息，此外 ``amd-smi`` 则提供命令行接口来操纵和监控amdgpu内核:

- ``docker inpsect ollama-amd`` 可以看到运行容器将host主机的GPU设备bind进入容器:

.. literalinclude:: container_direct_access_amd_gpu/container_devices
   :caption: 通过 ``inspect`` 指令检查容器bind的设备

- 通过 ``docker exec -it ollama-amd /bin/bash`` 进入运行容器内部检查: **需要单独安装 rocminfo 工具**

.. literalinclude:: container_direct_access_amd_gpu/install_rocminfo
   :caption: 由于Ollama精简镜像不包含维护工具，所以需要单独安装 ``rocminfo``

安装了 ``rocminfo`` 之后，在容器中就可以观察驱动信息: 直接执行 ``rocminfo`` 可以看到如下输出，验证了容器内部已经绑定了host主机的GPU设备:

.. literalinclude:: container_direct_access_amd_gpu/rocminfo_output
   :caption: ``rocminfo`` 输出信息

运行模型
=========

一切就绪，现在可以 :ref:`ollama_amd_gpu_docker`

参考
=======

- `Running ROCm Docker containers <https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html>`_
- `Docker hub: ollama <https://hub.docker.com/r/ollama/ollama>`_ 官方镜像提供了使用NVIDIA和AMD GPU容器的方法，非常实用
