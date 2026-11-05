.. _podman_compose_ollama_amd_mi50:

=============================================
Podman compose组合运行Ollama(AMD MI50 GPU)
=============================================

本文实践在 :ref:`docker_compose_ollama` 基础上改进:

- 尝试采用 :ref:`ubuntu_linux` 26.04 LTS运行 **失败** ， :strike:`并尽量采用AMD最新驱动和ROCm` 由于 :ref:`amd_mi50` 核心太老，官方只提供针对Ubuntu 24.04版本驱动，我常是使用发行版默认 amdgpu 驱动，但是Ollama容器似乎无法驱动GPU
- 吸取 :ref:`docker_compose_ollama` Ollama官方镜像默认不支持gfx906( :ref:`amd_mi50` )，改为社区维护的 `xxdoman/ollama-mi50 <https://hub.docker.com/r/xxdoman/ollama-mi50>`_

.. warning::

   :strike:`本文实践没有成功，AMD的显卡驱动向后兼容性不佳，` 

   在最新的 :ref:`ubuntu_linux` 26.04上顺利安装ROCm对应的 ``amdgpu`` 驱动，使用社区 ``amdgpu`` :strike:`似乎不支持ROCm。`

   我准备降级操作系统，再次针对我的古老的 :ref:`amd_mi50` 重新部署Ollama容器

ollama镜像
===============

- 下载 ``ollama/ollama:rocm`` 镜像( 需要设置 :ref:`podman_proxy` )

.. literalinclude:: podman_compose_ollama_amd_mi50/pull_ollama
   :caption: 下载 ``ollama/ollama:rocm`` 镜像

- 检查容器(镜像)中 :ref:`rocm` 版本: 

  - 宿主机 Driver 需要比容器内置的库更新或同代，才能实现兼容
  - ABI（应用二进制接口）大版本没有跨代撕裂: ROCm 同大版本内（如 6.x 系列之间）的 ``/dev/kfd`` 内核 API 保持高度一致。宿主机驱动只要能成功把 ``/dev/kfd`` 和 ``/dev/dri`` 暴露出来，容器内自带的 HIP 运行时（libamdhip64.so）就能直接通过 ioctl 系统调用顺利操作 MI50 显卡

.. literalinclude:: podman_compose_ollama_amd_mi50/version
   :caption: 检查ROCm版本

.. note::

   :ref:`amd_mi50` 是 Vega 20/ ``gfx906``

.. warning::

   既然 ``ollama/ollama:rocm`` 使用的是 AMD ROCm v7.2 系列，参考 `ROCm™ Software 7.2.4 <https://rocm.docs.amd.com/en/docs-7.2.4/>`_ 进行物理主机的AMD驱动安装(注意官方文档 `ROCm™ Software 7.2.4: System requirements (Linux) <https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.2.4/reference/system-requirements.html>`_ 将 ``AMD Instinct MI50`` / ``GCN5.1`` / ``gfx906`` 列为不支持设备。不过，我的这个尝试失败了: ROCm 7.2.4系列的 ``amdgpu`` 驱动是针对 :ref:`ubuntu_linux` 24.04所使用的旧版内核开发的，在Ubuntu 26.04的Kernel 7.0上 ``dkms`` 编译失败。

   **验证失败** 放弃安装官方 ``ROCm 7.2.4 amdgpu`` ，改为 :ref:`ubuntu_26.04_install_amdgpu` 实践中直接使用社区发布的 ``amdgpu`` 开源驱动。

Podman compose运行
====================

- 创建目录结构(用于存储镜像、模型数据等)

.. literalinclude:: podman_compose_ollama_nvidia_a2/tree
   :caption: 目录结构

.. literalinclude:: podman_compose_ollama_nvidia_a2/mkdir
   :caption: 创建目录

- :ref:`podman_compose` 和Docker compose兼容，所以也是用 ``docker-compose.yml`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/docker-compose.yml
   :caption: ``docker-compose.yml``

.. note::

   Ollama官方镜像当前已经不支持gfs906( :ref:`amd_mi50` )，这在我之前的实践 :ref:`docker_compose_ollama` 已经反复验证(失败)。

   根据 `xxdoman/ollama-mi50 <https://hub.docker.com/r/xxdoman/ollama-mi50>`_ 说明，采用这个针对MI50定制的镜像

启动以后务必检查 ``podman logs ollama-mi50`` ，输出信息如果显示 ``msg="inference compute" id=cpu library=cpu ...`` 则表明降级回了CPU模式，并没有实际使用GPU。则需要进一步排查...

- 在 ``~/podman/prometheus_data/`` 目录下创建 ``prometheus.yml`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/create_prometheus_yml
   :language: bash
   :caption: 创建 ``~/podman/prometheus_data/prometheus.yml``

.. note::

   墙内别忘记 :ref:`podman_proxy` ，不过需要注意，仅在从docker hub下载镜像是需要代理，正式运行 ``podman compose`` 整个系统时需要关闭代理，否则会引起容器间相互访问以及下载模型的阻塞。

- 启动容器:

.. literalinclude:: podman_compose_ollama_nvidia_a2/up
   :caption: 启动容器

- 参考 :ref:`podman_compose_ollama_nvidia_a2` ，需要首先运行一个支持 **Open-WebUI 内置了 RAG（检索增强生成）知识库检索功能** 的模型:

.. literalinclude:: podman_compose_ollama_amd_mi50/ollama_run_embed
   :caption: 加载nomic-embed-text

检查和确认
-------------

我的实践实际上再次遇到无法检测到GPU的问题，也就是 ``podman logs ollama-mi50`` 日志显示 ``msg="inference compute" id=cpu library=cpu ...``

目前的判断是 官方 ROCm 闭源/DKMS 驱动 对于 :ref:`amd_mi50` 以及 Ollama镜像使用的 ROCm 7.2 还停留在 Ubuntu 24.04 版本内核，我这次实践采用 Ubuntu 26.04，安装 ``amdgpu`` 编译失败，所以很可能无法支持容器运行。看起来AMD的驱动非常挑剔，我需要推倒操作系统降级为 24.04 重新尝试。

加载模型
============

- 按照 :ref:`model_choice` 规划，运行 ``qwen3-coder-next:q4_K_M`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/run_qwen3-coder
   :caption: 运行 `qwen3-coder-next:q4_K_M``

Grafana配置
=============

- AMD GPU 显卡监控(面板ID ``18913`` )

- Node Exporter Full(面板ID ``1860`` )

异常排查
==========

Rootless模式运行容器无法读写GPU设备
------------------------------------

我最初尝试 :ref:`ubuntu_linux` 26.04.1 LTS上通过发行版 ``amdgpu`` 驱动来作为底座，但是发现每次启动 ``ollama`` 容器( ``rocm`` tag)，始终报相同的识别为cpu，而不是rocm(gpu):

.. literalinclude:: podman_compose_ollama_amd_mi50/gpu_fail2_cpu
   :caption: 识别gpu失败回退为cpu
   :emphasize-lines: 2

这里观察到的 ``library=cpu`` 表明 ``ollama`` 最终是以CPU作为硬件来进行推理。

那么为何会导致这个问题？

我最初以为是Host主机 ``amdgpu`` 驱动安装失败导致的，因为官方 ``amdgpu-install`` 确实无法在 Ubuntu 26.04 系列的 Kernel 7.0上编译，显示 ``dkms`` 格式不兼容。

我最初按照gemini建议，索性就尝试使用Ubuntu发行版提供的 ``amdgpu`` 可不可行呢？整个部署过程按上文完成后，发现 ``ollama`` 容器还是运行日志显示 ``library=cpu`` ，也就是GPU识别失败。

我以为是社区 ``amdgpu`` 不支持 ``ROCm`` ，那我就回退操作系统到 Ubuntu 25.04.5 。很不幸，这个版本的内核 ``6.8.0-147-generic`` 居然执行 ``amdgpu-install`` 安装编译显示 ``dkms`` 的一个函数参数不一致(我不知道AMD开发的驱动为何没有跟随Kernel同步升级)，导致编译依然失败。

我仔细阅读了ROCm 7.2 RELEASE说明文档，发现文档中写了社区发行的 Ubuntu 24.04.3 是Inbox驱动支持，也就是说根本不需要再执行 ``amdgpu-install`` 直接用发行版内核的 ``amdgpu`` 驱动就应该支持 ROCm 7.2。那么我是用 Ubuntu 24.04.5 似乎也有可能是开箱即用的？

然而重新部署好 ``podman compose`` 运行起容器之后，报错依旧...

太折腾了，gemini提供了不同的建议，其中有一条突然触动了我: 检查一下容器内部GPU设备文件

我的 :ref:`podman` 是运行在 ``rootless`` 模式下的，我突然想到，这意味着在容器内部映射到Host上的属主就是我的普通账号 ``admin`` 。这种安全限制完全可能无法访问GPU设备文件:

- 在容器内部检查 ``GPU`` 设备文件:

.. literalinclude:: podman_compose_ollama_amd_mi50/dri_kfd_in_container
   :caption: 检查容器内部的 ``dri`` 和 ``kfd`` 设备

果然有异常，怎么设备文件的属主都是 ``nobody`` ?

.. literalinclude:: podman_compose_ollama_amd_mi50/dri_kfd_in_container_output
   :caption: 检查容器内部的 ``dri`` 和 ``kfd`` 设备显示属主是 ``nobody``

- 在对应物理主机上检查设备文件:

.. literalinclude:: podman_compose_ollama_amd_mi50/dri_kfd_in_host
   :caption: 检查物理主机的 ``dri`` 和 ``kfd`` 设备

发现端倪了，物理主机的读写权限是赋予 ``render`` 组用户的:

.. literalinclude:: podman_compose_ollama_amd_mi50/dri_kfd_in_host_output
   :caption: 检查物理主机的 ``dri`` 和 ``kfd`` 设备显示组用户是 ``render``

- 在物理主机上 ``admin`` 用户执行 ``id`` 命令看到的自身属于的组名( **没有包含render** ):

.. literalinclude:: podman_compose_ollama_amd_mi50/admin_group
   :caption: ``admin`` 用户不属于 ``render`` 组

也就是说，在Host主机上 ``admin`` 用户就无法读写GPU设备，那么运行在 ``rootless`` 模式下的容器继承了 ``admin`` 用户的权限，也就无法读写容器内映射的GPU设备了...

其实很多图形驱动安装手册都有一句要求把当前用户加入到 ``render`` 和 ``video`` 组才能使用图形界面的说明。但是在这次使用GPU设备做LLM推理，忘记执行这个步骤了...

- 将 ``admin`` 用户加入到 ``render`` 和 ``video`` 组，然后重新登录:

.. literalinclude:: podman_compose_ollama_amd_mi50/usermod
   :caption: 修订 admin 用户组添加到 ``render`` ``video`` 组

- 重新验证，发现此时容器内部 ``dri`` 和 ``kfd`` 设备还是显示为 ``nobody`` 属主，但是想到容器内的 ``ollama`` 进程是 ``root`` 运行，在 ``rootless`` 容器模式下映射到Host主机就是 ``admin`` ，怎么看也应该能访问GPU设备才对...

然而，发现 ``ollama`` 提示依然是 ``library=cpu`` ，毫无变化...

- 询问了gemini: **Rootless Podman 默认的安全隔离机制** 即使宿主机用户属于硬件组，由于内核的 User Namespace（用户命名空间）隔离，容器内进程直接访问 ``/dev/kfd`` 或 ``/dev/dri/renderD*`` 时，默认的设备 ``cgroup`` 或 ``SELinux/AppArmor`` 策略会拦截这种跨命名空间的硬件控制权，导致底层驱动无法初始化，从而静默回退到 CPU。

虽然但是...

我尝试修订 ``docker-compose.yml`` ，在 ``ollama-mi50`` 段落添加 ``privileged: true`` 开启特权模式:

.. literalinclude:: podman_compose_ollama_amd_mi50/ollama-mi50_privileged.yml
   :caption: 为 ``ollama-mi50`` 配置添加 特权模式
   :emphasize-lines: 6,8

然而还是不行，进入容器检查发现，无法读写 ``/dev/kfd`` 设备:

.. literalinclude:: podman_compose_ollama_amd_mi50/cat_kfd
   :caption: 无法读写 ``/dev/kfd`` 设备
   :emphasize-lines: 2

为什么特权模式也无法读写 ``/dev/kfd`` ? (gemini答复)

- **Rootless 的宿主机身份限制** : 在无根（Rootless）模式下，容器管理器本身是由普通用户(如 admin 用户)运行的。即使容器内部看起来是 root 用户，但在宿主机的 Linux 内核眼里，这个进程永远不具备真正的宿主机超级用户( ``CAP_SYS_ADMIN`` 等特权)。
- **备节点的命名空间隔离(User Namespace)** : ``/dev/kfd`` (AMD HSA 核心驱动设备) 和 ``/dev/dri/renderD*`` 是极其敏感的内核级硬件驱动节点。内核对这些设备的访问权限检查不仅看文件属主，还会校验打开设备的进程是否具有真实的内核管理权限。Rootless 容器由于受到用户命名空间的严格隔离，无法绕过内核对 ``/dev/kfd`` 的安全限制。
- **privileged 在 Rootless 下的妥协** : 在 ``Rootful`` (有根)Podman 中， ``privileged: true`` 可以赋予容器完全访问宿主机硬件的能力；但在 ``Rootless`` 模式下， ``privileged`` 权限是被严重阉割的，它无法赋予普通用户命名空间去直接操作诸如 ``/dev/kfd`` 这种底层异构计算驱动。

Rootful模式运行使用GPU设备的容器
----------------------------------

.. note::

   ``Rootfull`` vs. ``Rootless`` 参见 :ref:`intro_podman`

参考
======

- `ROCm™ Software 7.2.4: Quick start installation guide <https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.2.4/install/quick-start.html>`_
- gemini
