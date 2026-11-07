.. _podman_compose_ollama_amd_mi50:

====================================================
Podman compose组合运行Ollama(AMD MI50 GPU)
====================================================

概述
=======

准备工作
===========

- 创建一个 ``rootless`` 和 ``rootful`` 共享的bridge网络 ``ai-network`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/create_net
   :caption: 创建 bridge网络 ``ai-network``

- 创建目录结构(用于存储镜像、模型数据等)

.. literalinclude:: podman_compose_ollama_amd_mi50/dir
   :caption: 目录结构

.. literalinclude:: podman_compose_ollama_amd_mi50/mkdir
   :caption: 创建目录

``podman compose``
===================

``Rootful`` 容器
--------------------

访问 :ref:`amd_mi50` GPU设备的容器需要使用特权模式，并且需要采用 ``Rootful`` 模式运行:

- ``ollama-mi50``
- ``amdgpu-exporter``

.. literalinclude:: podman_compose_ollama_amd_mi50/docker-compose.rootful.yml
   :caption: 特权模式运行 ``docker-compose.rootful.yml``

说明:

- ``rootful`` 容器需要启用 ``privileged: true`` 特权模式，这样才能访问底层GPU设备(之前在 :ref:`podman_compose_ollama_amd_mi50_debug` 反复折腾的就是这个)
- 端口绑定采用了 ``0.0.0.0:11434:11434`` 这是因为 ``ollama-mi50`` 和 ``amdgpu-exporter`` 是运行在 ``Rootful`` 模式下，而其他 openwebui, prometheus, grafana 容器是运行在 ``Rootless`` 模式下，相互间不能通过短域名访问。这里采用了变通模式，将 ``Rootful`` 容器的服务端口绑定到Host主机上，这样就能被 ``Rootless`` 容器访问到
- Ollama相关设置请参考 :ref:`ollama_env`

启动容器:

.. literalinclude:: podman_compose_ollama_amd_mi50/rootful_up
   :caption: 指定 ``-f docker-compose.rootful.yml`` 启动 ``Rootful`` 容器

``Rootless`` 容器
--------------------

其他不需要访问Host物理主机设备的容器采用安全性更高的 ``Rootless`` 模式运行

.. literalinclude:: podman_compose_ollama_amd_mi50/docker-compose.rootless.yml
   :caption: rootless模式运行 ``docker-compose.rootless.yml``

在 ``

启动容器:

.. literalinclude:: podman_compose_ollama_amd_mi50/rootless_up
   :caption: 指定 ``-f docker-compose.rootless.yml`` 启动 ``Rootless`` 容器

验证
=======

- ``ollama-mi50`` 容器日志:

.. literalinclude:: podman_compose_ollama_amd_mi50/gpu.log
   :caption: 日志所有层加载到GPU

日志说明:

  - 100% 完整卸载 ( ``offloaded 49/49 layers to GPU`` ): 模型的所有 49 层权重被全部吃进显存，没有发生任何 CPU 降级或部分卸载。这意味着所有的矩阵乘法和推理计算都在 MI50 的并行计算单元上全速执行。
  - 双卡负载均分: 两张 MI50 显卡各自承担了大约一半的模型权重（总计近 50GB），实现了真正的多卡显存均分与协同推理。
  - 极小的 CPU 映射 ( ``CPU_Mapped model buffer size = 166.92 MiB`` ): 不到 200MB 的 CPU 占用只是常规的框架元数据或 CPU-Host 内存交互缓冲区，完全不影响整体推理性能。

grafana
=========

- ``norskhelsenett/ollama-metrics`` 使用该项目 `GitHub:NorskHelsenett/ollama-metrics <https://github.com/NorskHelsenett/ollama-metrics>`_ 源码中提动的面板配置文件

运行速度
========

当前从 ``podman logs -f ollama-mi50`` 观察日志来看:

- Prompt 评估阶段：268.89 tokens per second
- Token 生成阶段 (tg)：33.40 t/s 到 33.73 t/s (后期观察发现最稳定大约就是 30 t/s)

gemini提示: 对于 50多GB 的大模型，双卡 MI50 能跑出每秒 30+ Token 的生成速度是非常正常的硬件表现

异常排查
==========

``amdgpu`` 的 ``page fault``
-----------------------------

运行 ``qwen3-coder-next:q4_K_M`` 模型，运行异常中断，从 ``ollama-mi50`` 容器日志看到:

.. literalinclude:: podman_compose_ollama_amd_mi50/llama-server_terminated.log
   :caption: ``llama-server terminated`` 异常日志
   :emphasize-lines: 2

在Host主机操作系统日志中显示 ``no-retry page fault`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/llama-server_terminated_no-retry_page_fault.log
   :caption: 操作系统日志显示 ``no-retry page fault`` 错误

这个问题可能和 ``Open-WebUI`` 的 ``num_ctx`` 设置项有关，我当前先调整为 ``4096`` ，运行暂时没有问题。

kfd_process_wq_release [amdgpu] hogged CPU
--------------------------------------------

按照gemini建议，在我的双 :ref:`amd_mi50` 具有64GB显存，运行 ``qwen3-coder-next:q4_K_M`` 模型，大约可以开启上下文长度 ``num_ctx`` 约 ``8196`` 。我尝试了这个设置，发现确实没有出现 ``amdgpu`` 的 ``page fault`` 报错。但是，我的处理器性能不足，当推理时候CPU负载极高，系统dmesg日志中会出现:

.. literalinclude:: podman_compose_ollama_amd_mi50/kfd_process_wq_release_hogged_cpu.log
   :caption: 触发 hogged CPU for >10000us 警告

:strike:`这个问题我准备通过升级操作系统到Ubuntu 26.04 LTS HWE来看看是否改善，目前将 num_ctx 降级到 6144 能明显改善，但是也会有偶然出现相同报错。看来4198比较保险，或者通过升级内核或者CPU硬件来解决？`

这个问题和gemini讨论下来 :ref:`ollama_workqueue_optimize` 有两个影响因素需要优化:

- 需要 :ref:`iommu_grub_config` (参见 :ref:`iommu_infra` )
- 调整 :ref:`ollama_num_ctx` （启动的默认上下文长度是 ``256K`` )
