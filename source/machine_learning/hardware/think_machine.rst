.. _think_machine:

=========================
思考机器
=========================

我最初采用 ref:`hpe_dl380_gen9` 来安装运行 :ref:`tesla_a2` 和 :ref:`amd_radeon_instinct_mi50` ，但是DL380这样的机架式服务器噪音极大，在家中使用非常不便。

我后来想采用自己组装台式机来降低噪音，类似 :ref:`hp_z8_g4` 那样(虽然我也尝试过Z8，但是太贵了而且运气不好买到了存在硬件缺陷的准主机，最后放弃)能够同时兼顾多GPU且静音的主机。

虽然最初我的想法比较模糊，我只考虑到体积小巧，选购了 :ref:`nasse_c246` ，确实存在PCIe扩展限制。但是经过反复尝试和改进方案，最终还是能够支持4块GPU的怪兽:

- 两块 :ref:`amd_radeon_instinct_mi50`
- 两块 :ref:`tesla_a2`

.. note::

   目前我投入资金的GPU最佳性能硬件是 :ref:`amd_radeon_instinct_mi50` 和 :ref:`tesla_a2` ，通过改造硬件来实现现有硬件投入的充分利用。
 
硬件
=========

:ref:`nasse_c246` 的主板虽然只有 **1个PCIe 3.0接口** ，但是通过 :ref:`gpu_bios` 设置，能够将一个PCIe x16通过 :ref:`pcie_bifurcation` 拆分成 ``x4x4x8`` 实现连接 **3个PCIe设备** 

那么第4个GPU设备是如何连接到 :ref:`nasse_c246` 主板的呢?

答案就是 ``OCuLink`` 连接到 :ref:`nasse_c246` 的一个 M2 接口上，采用很久以前 :ref:`pi_egpu_ml_arch` 实践时购买的外接eGPU转接卡实现。

不过，需要考虑 :ref:`amd_radeon_instinct_mi50` 是能耗怪兽，TDP高达300W，建议电源700W。当安装两块MI50时，我当时购买的利民TGFX-750W实际上非常勉强。为了能够稳定运行，我准备做一个改造，利旧自己在 :ref:`hpe_dl380_gen9` 配套的1400w服务器电源作为 :ref:`egpu_server_power`
