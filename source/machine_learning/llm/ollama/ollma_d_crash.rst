.. _ollma_d_crash:

===============================
Ollama异常:大量kworker ``D``
===============================

我在使用 :ref:`ollama_amd_gpu` ，向 :ref:`qwen2.5-coder` 询问了一个中文问题 "法国的首都是哪里?" ，结果发现ollama客户端长时间没有响应并突然推出(进程显示为 ``defunc`` )。

此时检查发现系统负载极高，Load超过 250+，但同时CPU是完全空闲的。

.. literalinclude:: ollma_d_crash/top
   :caption: 检查 ``top`` 输出
   :emphasize-lines: 1

既然cpu没有压力，但是load高，那么应该是有进程 ``D`` 住了

- 检查哪些进程 ``D`` 住了:

.. literalinclude:: ollma_d_crash/ps
   :caption: 使用 ``ps`` 检查进程D

- 根据进程，检查堆栈:

.. literalinclude:: ollma_d_crash/stack
   :caption: 检查D住进程堆栈
   :emphasize-lines:  4,14,15,25

可以看到都是 ``amdgpu`` 相关进程陷入等待

- 检查 ``dmesg`` 可以看到hang住的异常:

.. literalinclude:: ollma_d_crash/dmesg
   :caption: ``dmesg`` 异常hang日志

从 ``amdgpu: Freeing queue vital buffer 0x75acbea00000, queue evicted`` 报错拉坎，似乎AMD GPU驱动( ``admgpu`` ) 在释放一个GPU队列的内存buffer时(evicted驱逐)出现了错误: 也可能驱动程序重置了队列或GPU

  - GPU重置: AMDGPU 驱动程序可能已启动特定 GPU 队列（甚至整个 GPU）的重置，以从检测到的错误中恢复
  - 应用程序崩溃: 应用程序故障或驱动程序问题可能导致 GPU 队列变得不稳定或无响应，从而促使驱动程序将其清除
  - 硬件问题：这种情况不太常见，也可能表明 GPU 硬件本身存在问题

.. note::

   在 ``dmesg`` 中显示的 ``amdgpu_tlb_fence_work`` 是AMDGPU Linux内核驱动程序中 Translatio Lookaside Buffer (TLB, 转译后备缓冲器，页表缓存，转址旁路缓存)，是计算机体系结构中用于加速虚拟地址到物理地址转换的一种硬件缓存结构。TLB位于内存管理单元(MMU)中，用于存储最近使用的虚拟页号到物理页帧号的映射关系，避免每次访问内存时都查询慢速的页表，从而提升系统性能。

   TLB页表缓存，是CPU访问虚拟地址首先在TLB中查找对应的物理地址，如果TLB没有命中，CP就需要到主内存中查询页表，并将这个映射关系添加到TLB中，以便下次访问。

   TLB失效/刷新: 当内存映射发生变化(例如，某个页面宝贝释放，重新映射或其权限发生更改)时，TLB中相应条目可能会陈旧或无效。为避免使用这些陈旧条目，系统必须将它们从TLB中失效或刷新，确保CPU始终使用正确的最新的内存映射。这里 ``fence`` 栅栏表示同步，确保某些操作(例如内存写入或TLB刷新)在其他操作开始前完成。

   ``amdgpu_tlb_fence_work`` 应该是GPU内存映射被修改时维护内存一致性和正确性，进行TLB更新以反映最新内存状态。
