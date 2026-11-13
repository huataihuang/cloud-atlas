.. _nvidia_dcgm_nv-hostengine_dcgm-exporter:

====================================================
NVIDIA DCGM, nv-hostengine, dcgm-exporter 关系梳理
====================================================

以前在蚂蚁金服工作时，在 :ref:`kubernetes` 集群部署 :ref:`dcgm-exporter` 是采用 :ref:`nvidia_gpu_operator` 自动完成的，这种一体化运维非常丝滑，但是也屏蔽(让人忽视)了底层 :ref:`nvidia_dcgm_infra` 的组件关系。

当我在 homelab 环境模拟演练时，采用了 :ref:`podman_rootless_mode_dcgm-exporter` 来部署 :ref:`podman_compose_ollama_nvidia_a2` ，梳理了 ``DCGM => nv-hostengine <= dcgm-exporter`` 关系:

- 宿主机端: :ref:`nvidia_dcgm` 核心服务(Server / Host Engine)

  - NVIDIA 官方提供的底层硬件管理与诊断套件。它包含核心守护进程 ``nv-hostengine`` 以及驱动库。
  - ``nv-hostengine`` 需要直接和NVIDIA内核驱动(NVIDIA Driver)通信、调用底层NVML(NVIDIA Management Library)、直接读取 GPU 硬件的寄存器、温度、功耗、PCIe 错误等底层物理指标。
  - 如果通过容器运行 ``nv-hostengine`` (即运行 ``nvidia/cuda`` 镜像)，必须使用 ``rootful`` 模式
  - 抓取精确的 GPU 硬件指标，宿主机层面的 DCGM 驱动包是前置依赖

- ``nv-hostengine`` 是 :ref:`nvidia_dcgm` 的核心服务

  - ``nv-hostengine`` 属于 DCGM：它不是独立的第三方软件，而是 DCGM 官方套件中用来在后台提供 API 服务的核心引擎。

- 容器端: :ref:`dcgm-exporter` (Client/客户端)

  - 纯粹的 Prometheus 指标转换器(Exporter)
  - 本身不直接和硬件内核打交道。它的唯一工作是向 ``nv-hostengine`` 发起 RPC 请求，把获取到的底层 GPU 数据转换成 Prometheus 能够识别的时序指标格式（如 ``DCGM_FI_DEV_GPU_TEMP`` ），并对外暴露 ``9400`` 端口。
  - ``dcgm-exporter`` 依赖 ``nv-hostengine`` : ``dcgm-exporter`` 在工作时，必须通过本地或远程端口（如 ``5555`` ）连接到一个正在运行的 ``nv-hostengine`` 实例，否则它无法获取任何 GPU 指标。
  - :ref:`dcgm-exporter` 镜像中包含了 ``nv-hostengine`` ，但是没有包含完整的 :ref:`nvidia_dcgm` ，并且默认运行时认为自己是 ``Rootful`` 模式的容器，也就是容器必须拥有极高的特权，并挂载宿主机的底层套接字，才能在容器中成功唤醒硬件监控。

.. csv-table:: DCGM, nv-hostengine, dcgm-exporter 关系
   :file: nvidia_dcgm_nv-hostengine_dcgm-exporter/relationship.csv
   :widths: 20,30,50
   :header-rows: 1
