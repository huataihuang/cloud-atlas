.. _ollama_init_tunning:

===================================
Ollama的启动参数调整(AMD MI50)
===================================

我在观察 ``Ollama`` 容器日志时发现如下信息:

.. literalinclude:: ollama_init/ollama_load
   :caption: Ollama启动信息
   :emphasize-lines: 3,5

不过，受限于我的 :ref:`dell_t5820` 孱弱的PCIe 3带宽，超长上下文( ``num_ctx = 262144`` , 256K)和较大的批大小( ``num_batch = 512`` )会导致反复出现:

.. literalinclude:: podman_compose_ollama_amd_mi50/llama-server_terminated_no-retry_page_fault.log
   :caption: 操作系统日志显示 ``no-retry page fault`` 错误

调整启动参数
==============

Ollama提供了通过 ``Modelfile`` 来在原有模型基础上调整元数据来调整启动参数

- 创建 ``Modelfile`` :

.. literalinclude:: ollama_init_tunning/Modelfile
   :caption: 调整参数的 Modelfile

这里不需要设置  ``num_ubatch`` (Ollama不认这个参数调整，该值自动和 ``num_batch`` 一致)

- 创建新的模型(类似于 :ref:`docker` 的文件层，实际上仅仅需要很少的磁盘空间):

.. literalinclude:: ollama_init_tunning/ollama_create
   :caption: 创建模型

.. note::

   这个batch大小需要按照自己的软硬件环境不断尝试以获得最合适的参数，目前我尝试下来 ``128`` 恰好能够避免出现 ``no-retry page fault`` 错误。

上述调整，按照我的想法，优先调整 ``batch size`` (影响推理速度)，尽量不缩小 ``num_ctx`` (上下文窗口大小影响模型能够处理文档长度，也就是影响能力)。
