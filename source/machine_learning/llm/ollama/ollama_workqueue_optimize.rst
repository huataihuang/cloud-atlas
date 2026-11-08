.. _ollama_workqueue_optimize:

==============================
Ollama系统workqueue优化
==============================

.. note::

   本文是实践中的一些笔记和尝试优化，目前我对这方面知识积累不足，还需要学习提高。本文会不断改进...

page fault
============

在 :ref:`podman_compose_ollama_amd_mi50` 实践发现 ``open-webui`` 反复出现生成内容中断问题，从服务器的终端和 ``dmesg`` 日志提示:

.. literalinclude:: podman_compose_ollama_amd_mi50/llama-server_terminated_no-retry_page_fault.log
   :caption: 操作系统日志显示 ``no-retry page fault`` 错误

这个问题gemini提示可能和 ``Open-WebUI`` 的 ``num_ctx`` 设置项有关，我当前先调整为 ``4096`` 。目前还没有复现，不过后续和gemini讨论，在 ``Open-WebUI`` 调整上下文长度 ``num_ctx`` 仅对 ``open-webui`` 调动 Ollama 首次加载模型才能生效，如果模型已经在Ollama中加载，则 ``open-webui`` 设置的这个 ``num_ctx`` 不生效，而取决于模型加载的参数。

不过，这个 ``open-webui`` 的参数设置对于 Ollama 是 **有意义** 的，因为我发现如果在 ``open-webui`` 中保持默认的 ``num_ctx(Ollama)`` **default** ，那么调用和启动Ollama模型显示是使用 ``256K`` 上下文 ( :ref:`ollama_init` ``n_ctx = 262144`` )改成更小的上下问或者调整batch大小:

经过实践，在不牺牲上下文大小的情况下(以便能处理更多文本)，通过 :ref:`ollama_init_tunning` 将默认 ``batch`` 大小从 512 改成 128，就能够在我的硬件组合下解决这个 ``page fault`` 问题。


workqueue死锁
================

反复出现的现象是系统 ``dmesg -T`` 日志显示 ``workqueue`` 出现死锁:

.. literalinclude:: podman_compose_ollama_amd_mi50/kfd_process_wq_release_hogged_cpu.log
   :caption: 触发 hogged CPU for >10000us 警告

此时会出现 ``open-webui`` 突然中断正在大量吐出的文字内容，似乎是 ``open-webui`` 和后端 ``ollama`` 的网络连接断开。

gemini提示:

- ``workqueue: iova_depot_work_func hogged CPU for >10000us`` 表示 ``IOVA`` (I/O Virtual Address)隔离与内存映射的工作队列占用了过长的CPU实践(超过10ms)

由于我使用了大显存占用的 ``qwen3-coder-next:q4_K_M`` ，大约需要使用 52+ GB 显存，所以会被Ollama按层切分分布到2块 :ref:`amd_mi50` 行。在推理过程中，需要进行频繁的层间张量传输、或者管理庞大的KV Cache动态内存映射和劫持映射。当并发或超长上下文导致显存与系统内存频繁交互时，就会触发这个内核警告，表现为短暂的CPU队列堵塞。

- ``workqueue: drm_fb_helper_damage_work hogged CPU for >10000us`` 表示 Direct Rendering Manager（DRM）图形帧缓冲区刷新工作队列占用了 CPU

由于系统整体处于高负载或总线忙碌状态，导致 UI 刷新线程被暂时阻塞。它本身不影响 AI 推理，但说明高负载下整机响应受到了牵连。

解决思路
-----------

这类 ``hogged CPU for >10000us`` (超过 10ms)属于内核的 ``Soft Lockup`` / ``Latency Warning`` 。在运行大模型、大内存分配的场景下偶发出现是比较常见的，不一定会导致系统崩溃，但它会让用户感受到的 “CPU 队列锁 / 卡顿感”。

- :ref:`iommu_grub_config`


