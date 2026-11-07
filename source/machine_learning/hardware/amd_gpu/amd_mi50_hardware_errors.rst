.. _amd_mi50_hardware_errors:

=============================
AMD MI50硬件报错
=============================

.. note::

   本文记录故障问题，待后续看是否持续出现或能否改善

目前在 :ref:`podman_compose_ollama_amd_mi50` 实践，采用了 :ref:`ollama_workqueue_optimize` 调整 :ref:`iommu` 之后，确实感觉卡顿和 ``workqueue`` 报错少了，但是却发现有硬件报错，集中在一块GPU上:

- 目前怀疑可能是散热不均匀或者功率问题导致一块卡存在功耗墙问题

.. literalinclude:: amd_mi50_hardware_errors/dmesg
   :caption: 硬件报错

.. warning::

   **严重硬件错误警报 (Uncorrectable Hardware Errors)**

   这组 dmesg 日志反映了一个非常严重且不能忽视的硬件级错误。日志中明确出现了 ``uncorrectable hardware errors detected in gfx block`` （图形/计算核心单元检测到不可纠正的硬件错误），这意味着 GPU 在执行大规模张量计算（大模型推理）时，其内部计算单元或缓存发生了数据损坏，且无法通过硬件 ECC 修复。

``uncorrectable hardware errors in gfx block`` : 在运行大模型推理时，其 Vega 20 核心的 GFX（图形与计算）管道、着色器阵列或 L2 缓存遇到了过载、电压不稳、频率过高或硅片老化导致的计算异常。

可嫩原因:

- (这条可能性较小，因为我刷 V420 Pro VBIOS文档中说明是降频和降低功率的) gemini 提醒可能有刷Pro VBIOS之后，核心频率或功耗墙被解锁。在 256K 超长上下文、双卡高带宽并行计算时，瞬时负载极高，可能超出了当前 VBIOS 固件下的电压安全边界。
- 供电瞬时压降（Power Droop）：Dell T5820 的电源供电或转接线在双卡满载时，如果供电瞬态响应跟不上，会导致 GPU 核心微幅掉压，从而引发硬件计算错误。
- 散热或积热问题：MI50 作为服务器/工作站级显卡，若改装风扇或风道散热不良，核心局部过热也会导致硬件单元抛出 ECC/RAS 错误。

目前我的GPU卡散热风扇转速是通过调节器手工调节，我为了降低噪音采用了较低的转速。由于是从主机硬盘供电转出的2个风扇工单，有可能两个风扇的散热转速不同。我准备通过手工调节转速加快风扇速度看看是否能解决。

.. figure:: ../../../_static/machine_learning/hardware/amd_gpu/mi50_temperature.png

   两块GPU的最高温度相差13度，可能存在散热异常问题
