.. _intro_intel_pcm:

=======================================================
Intel Performance Counter Monitor (Intel PCM) 简介
=======================================================

Intel Performance Counter Monitor (Intel PCM) 是Intel公司开发的用于监控Intel处理器的性能和功耗的API以及基于这个API的一系列工具。PCM可以在Linux, Windows, Mac OS X, FreeBSD等操作系统工作 。

.. warning::

   根据 ``pcm`` 输出可以看到对CPU硬件以及操作系统配置有强要求，我的输出信息中有部分错误，待后续实践改进

PCM提供了一系列命令行工具用于实时监控:

- ``pcm`` ：基础的处理器监控工具(每个cycle的指令，核心频率-包括 :ref:`intel_turbo_boost_pstate` ，内存，Intel快速路径内部连接带宽(Intel Quick Patch Interconnct bandwidth)，本地和远程内存带宽，缓存未命中，core和CPU封装(CPU package)睡眠C-state定位(residency)，core和CPU封装的热余量(thermal headroom)，缓存使用，CPU和内存能耗(energy consumption)。

.. literalinclude:: intro_intel_pcm/pcm_output
   :caption: pcm输出中能够观察到缓存命中情况以及处理器核心温度(解读需要较多知识积累，待续...)
   :emphasize-lines: 26-37

- ``pcm-sensor-server`` : 通过http以 ``JSON`` 或者 :ref:`Prometheus` (基于文本的 :ref:`pcm-exporter` )格式输出

- ``pcm-memory`` : 监控内存带宽(每个通道和每个DRAM DIMM rank):

.. literalinclude:: intro_intel_pcm/pcm-memory_output
   :caption: pcm-memory 输出可以看到内存通道的读写速率

- ``pcm-accel`` : `监控Intel® In-Memory Analytics Accelerator (Intel® IAA), Intel® Data Streaming Accelerator (Intel® DSA) and Intel® QuickAssist Technology (Intel® QAT) accelerators <https://github.com/intel/pcm/blob/master/doc/PCM_ACCEL_README.md>`_ (我没有这样的设备)

- ``pcm-latency`` : 监控一级缓存未命中和DDR/PMM内存延迟

.. literalinclude:: intro_intel_pcm/pcm-latency_output
   :caption: pcm-latency 输出可以看到内存通道的读写速率

- ``pcm-pcie`` : 监视每个socket的PCIe带宽

.. literalinclude:: intro_intel_pcm/pcm-pcie_output
   :caption: pcm-memory 输出可以看到内存通道的读写速率
   :emphasize-lines: 49-50

- ``pcm-iio`` : 监视每个PCIe设备的带宽(需要CPU支持 :ref:`intel_rdt` 我的 ``E5-2670 v3 @ 2.30GHz`` 支持不完整，在这个命令直接退出，后续再研究一下 :ref:`intel_rdt` )

- ``pcm-numa`` : 检查 :ref:`numa` 本地和远程内存访问

- ``pcm-power`` : 监控处理器的睡眠和能源状态、Intel Quick Path Interconnect、DRAM 内存、CPU 频率限制的原因以及其他能源相关指标

- ``pcm-tsx`` : 监控 Intel 事务同步扩展(Transactional Synchronization Extensions)的性能指标

- ``pcm-core`` 和 ``pmu-query`` ：查询和监视任意处理器核心事件

- ``pcm-raw`` ：通过指定原始寄存器事件 ID 编码来编程任意核心和非核心事件

- ``pcm-bw-histogram`` ：收集内存带宽利用率直方图

和监控平台集成
==================

通过 :ref:`pcm-exporter` 可以将 ``pcm`` 的监控指标输出到 :ref:`pcm-grafana`

安装
=======

主流发行版已经集成提供了 ``pcm`` 软件包，例如 :ref:`ubuntu_linux` 安装非常方便:

.. literalinclude:: intro_intel_pcm/ubuntu_install_pcm
   :caption: 在Ubuntu安装Intel PCM

参考
======

- `Intel Performance Counter Monitor (Intel PCM) (GitHub) <https://github.com/intel/pcm>`_
