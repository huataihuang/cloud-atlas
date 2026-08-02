.. _xeon_w-2225_openvino:

================================
Intel Xeon W-2225环境OpenVINO
================================

.. note::

   本文和gemini进行讨论后整理

我的 :ref:`dell_t5820` 存在 :ref:`dell_t5820_gpu` 缺陷，无法使用 :ref:`tesla_a2` 和 :ref:`amd_mi50` 这样的数据中心GPU运算卡，所以我考虑在现有硬件环境 :ref:`xeon_w-2225` 充分发挥 :ref:`vnni` 潜力来加速 LLM 推理。

:ref:`xeon_w-2225` 是Intel 2019年发布的Cascake Lake(14nm)微架构，虽然物理核心 ``4 核 / 8 线程`` 较弱，但是已经支持 ``AVX-512`` 和 ``Intel DL Boost (VNNI)`` (Intel专用于加速INT8矩阵乘法的指令集，OpenVINO和 :ref:`llama.cpp` 都能调用)。

Intel Xeon W-2225 推理性能预估
================================

:ref:`xeon_w-2225` 是 4 通道 ``DDR4-2933`` ，也就是理论最大内存带宽:

.. literalinclude:: xeon_w-2225_openvino/memory_bandwidth
   :caption: 当使用 DDR4-2933 内存是理论带宽

在多核并发下，可稳定达到的物理极限带宽约为 ``70GB/s``

``Xeon W-2225`` 虽然具有256GB内存，理论上可以塞下极大的模型，但是由于内存带宽限制(以70GB/s极限带宽来推测)

.. csv-table:: ``Xeon W-2225`` 4-bit量化速度预测
   :file: xeon_w-2225_openvino/4-bit.csv
   :widths: 20,20,20,40
   :header-rows: 1

当使用 Intel OpenVINO 进行加速时:

- 原理: 把 PyTorch 模型转换成 OpenVINO 专有的 IR (Intermediate Representation) 格式，并深度调用 Cascade Lake 的 AVX-512 :ref:`vnni` 硬件指令集进行 INT8/INT4 极速矩阵运算
- 优势: 在 Intel 芯片上的极限吞吐量通常是所有引擎中最高
- 劣势: 

  - 转换链路复杂: 必须通过 optimum-cli 命令行将 Hugging Face 原生 PyTorch 格式先转换并量化为 OpenVINO 格式，该转换过程极度消耗 CPU 和内存，且容易出错
  - 生态相对封闭: 对最新的混合架构（如 MoE 架构 DeepSeek-V3/R1）支持较慢

当使用 :ref:`ollama` ( :ref:`llama.cpp` )时:

- 开箱即用: 直接支持业界标准的 GGUF 格式模型，可以直接使用Hugging Face提供的 .gguf 文件
- 生态极其繁荣: 会随着前沿开源模型发布迅速释出GGUF版本
- 零配制启动: 通过 Ollama 一键启动，提供标准 OpenAI 兼容的 API

使用Ollama在某些特定 Intel 架构上的极限吞吐量比 OpenVINO 稍慢10%~20%，但由于其易用性，这部分差距在工程实践中完全可以接受。

``DDR4-2400`` 内存和优化
============================

Rank Interleaving（秩交错激活）
--------------------------------------

我现在使用的利旧内存是 ``三星 32G 2R*4 2400T`` 内存颗粒，运行频率是 ``2400 MT/s`` ，相当于 ``2933 MT/s`` 的 ``81.8%`` ，不过插满 8 根内存（256GB）的布局:

- ``2 DPC (DIMMs Per Channel)`` : Xeon W-2225 是 **4 通道 处理器** ，Dell T5820 提供了 8 个插槽。插满 8 根意味着 ``每个通道分配了 2 根内存`` 。
- ``2R (Dual Rank) 规格`` : 每根内存是双秩的，即 每个通道上挂载了 2x2= ``4个Rank`` (秩,zhì)

**Rank Interleaving（秩交错）** :

- 当 **通道上挂载了 4 个 Rank** ，内存控制器可以启动极其激进的 ``Rank Interleaving（秩交错激活）`` : 在Rank 0还在传输数据时，提前去预充电Rank 1，在Rank 1 传输时去预充电 Rank 2
- 当激活 ``Rank Interleaving（秩交错激活）`` 之后，内存利用效率(Bus Efficiency)会达到理论带宽 ``85%~90%`` 以上(例如相同CPU只插4根2933MHz的单秩1R内存，虽然理论带宽更高，但是由于缺乏Rank交错，实际有效带宽可能跟8根2400MHz的双秩内存几乎一样)

.. note::

   ``Rank Interleaving（秩交错激活）`` 是纯粹的 **硬件/微架构级特征** ，由CPU内部的 **集成内存控制器(IMC, Integrated Memory Controller)** 与主板BIOS在POST(开机自检)阶段自动完成握手并激活。它无法通过操纵系统(OS)层面的软件开关进行控制，激活完全遵循以下规则:

   - 当 IMC 检测到完美对称的物理布局时，它会自动开启最高级别的交错模式: 连续的物理内存地址会被打散并均匀映射到所有通道和 Rank 上
   - BIOS 需要开启 ``Memory Interleaving`` ( **Auto** 或 **Enabled** )，并且关闭 ``Node Interleaving`` (节点交错 **Disabled** ): 因为单路没有跨Socket的NUMA节点，启用 ``Node Interleaving`` 会导致BIOS强行模拟非对称NUMA，反而劣化性能

   最后在操作系统中执行 ``dmidecode`` 验证所有内存是否工作在预期的物理状态:

   .. literalinclude:: xeon_w-2225_openvino/dmidecode
      :caption: 检查内存工作状态

   我的T5820输出显示如下:

   .. literalinclude:: xeon_w-2225_openvino/dmidecode_output
      :caption: 检查内存工作状态

关闭透明大页(Disable THP)
-----------------------------

:ref:`huge_memory_pages` 对于虚拟化EPT(嵌套页表)映射、内核MMIO能带来极大的性能提升。因为内存大页将虚拟地址到物理地址的转换页表级数从4级减少到了更少，大幅降低了TLB(Translation Lookaside Buffer) Misses。

但是 :ref:`transparent_huge_page` 是Linux内核为了对应用层"透明"引入的动态管理机制。应用层依然分配普通的4KB页面，而内核后台有一个名为 ``khugepaged`` 守护进程不断扫描进程的虚拟内存空间，当发现有连续的、满足条件的4KB页面时，就会尝试将他们 **合并(Collapse)并重新整理(Compaction)** 成一个2MB的大页。

对于大模型CPU推理时，这个THP机制会带来灾难性的"微卡顿"(Jitter/Latecy Spikes):

- 内存锁争抢(Memory Allocation Stall): LLM推理是， :ref:`llama.cpp`  会频繁且高速地分配、释放临时张量、KV Cache缓存。当 ``khugepaged`` 在后台执行内存规整(Compation)是，它必须获取页表锁(Page Table Locks)并暂停相关的内存读写。此时，正在进行矩阵乘法的CPU线程会被挂起等待(I/O CPU Lockup)
- 延迟飙升(Latency Spikes): 在运行大模型是，可能会发现速度剧烈波动，例如毫无朕兆地卡顿1.5秒然后恢复。这通常就是 ``khugepaged`` 正在强制锁定和挪移模型权重内存页面导致的。

所以 :ref:`redis` , MangoDB, :ref:`elasticsearch` 官方文档以及所有主流深度学习推理框架，都一致强烈要求关闭THP的原因。

``madvise`` 模式
-------------------

但是，如果服务器环境确实需要 :ref:`transparent_huge_page` 技术来提升性能(降低TLB Misses,提升内存寻址效率)，又要避免 ``khugepaged`` 后台扫描带来的锁突发延迟，则应该采用 **业界标准的混合优化方案** ：

**启用madvise** :

.. literalinclude:: xeon_w-2225_openvino/madvise
   :caption: 启用 ``madvise``

此时 ``khugepaged`` 守护进程将不再主动、强制地去扫描和锁定普通进程的内存，消除了随机卡顿。

而 :ref:`llama.cpp` 或 :ref:`pytorch` 这种高性能程序自己写了内存管理(通过 ``madvise(..., MADV_HUGEPAGE)`` 系统调用)，在需要时依然可以主动申请2MB大页，享受到大页带来的寻址加速。

Static Huge Pages（静态大页）
-----------------------------------

追求极致的吞吐量，可以彻底关闭 THP，转而在引导时直接分配静态大页（HugeTLB），并在启动 llama.cpp 时挂载。

- 在引导时保留静态 2MB 大页（例如保留 50GB 专门给模型加载），修改 ``/etc/sysctl.conf`` 加入:

.. literalinclude:: xeon_w-2225_openvino/sysctl.conf
   :caption: 修订 /etc/sysctl.conf 设置静态大页

执行 ``sudo sysctl -p`` 生效。

- 挂载 hugetlbfs 并在 llama.cpp 中显式调用

现代版本的 llama.cpp 通过内存映射（mmap）来载入模型，通过将模型文件或分配池绑定到静态大页，可以让物理内存寻址效率达到绝对的物理极限，且运行期间零抖动、零卡顿。
