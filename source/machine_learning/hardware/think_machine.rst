.. _think_machine:

=========================
思考机器
=========================

我最初采用 :ref:`hpe_dl380_gen9` 来安装运行 :ref:`tesla_a2` 和 :ref:`amd_mi50` ，但是DL380这样的机架式服务器噪音极大，在家中使用非常不便。

我后来想采用自己组装台式机来降低噪音，类似 :ref:`hp_z8_g4` 那样(虽然我也尝试过Z8，但是太贵了而且运气不好买到了存在硬件缺陷的准主机，最后放弃)能够同时兼顾多GPU且静音的主机。

虽然最初我的想法比较模糊，我只考虑到体积小巧，选购了 :ref:`nasse_c246` ，确实存在PCIe扩展限制。

- :strike:`2块` :ref:`amd_mi50`
- :strike:`2块` :ref:`tesla_a2`



.. note::

   目前我投入资金的GPU最佳性能硬件是 :ref:`amd_mi50` 和 :ref:`tesla_a2` ，通过改造硬件来实现现有硬件投入的充分利用。
 
硬件
=========

组装机
-------------

:ref:`nasse_c246` 的主板虽然只有 **1个PCIe 3.0接口** ，但是通过 :ref:`gpu_bios` 设置，能够将一个PCIe x16通过 :ref:`pcie_bifurcation` 拆分成 ``x4x4x8`` 实现连接 **3个PCIe设备** 

那么第4个GPU设备是如何连接到 :ref:`nasse_c246` 主板的呢?

答案就是 ``OCuLink`` 连接到 :ref:`nasse_c246` 的一个 M2 接口上，采用很久以前 :ref:`pi_egpu_ml_arch` 实践时购买的外接eGPU转接卡实现: :ref:`tesla_p10`

但是上述架构有一个隐含的缺陷，在低端台式机上，兼容主板只支持1条PCI3 3.0的x16，通过 :ref:`pcie_bifurcation` 能够获得 ``x4x4x8`` 的3个插槽，但是也就止步于此。主板通过PCH南桥能够获得大约x4的带宽，但是是分配给2个 ``m.2`` 接口使用，虽然我购买了 ``OCuLink`` 扩展卡，理论上能够再多接2块GPU，但是实际上由于PCH南桥 ``x4`` 带宽共享给2个GPU，会出现带宽争抢。而且当采用5块A2并行推理，实际上有2块A2是拖累整体运行效率(可能只有一半)。所以我考虑最终在 :ref:`nasse_c246` 只安装3块A2计算卡，另外通过QCuLink来连接1块 :ref:`tesla_p10` 做延迟不敏感的 :ref:`stable_diffusion` 以及OCR等工作。

.. note::

   考虑 :ref:`amd_mi50` 是能耗怪兽，TDP高达300W，建议电源700W。当安装两块MI50时，我当时购买的利民TGFX-750W实际上非常勉强。为了能够稳定运行，一种思路是利旧自己在 :ref:`hpe_dl380_gen9` 配套的1400w服务器电源作为 :ref:`egpu_server_power`

:ref:`dell_t5820`
-------------------

不过，经过反复对比自组主机的稳定性和成本之后，我转向采用二手品牌工作站:

- 只有主流品牌的工作站能够提供经久耐用的硬件以及稳定性，并且二手市场大量提供的品牌工作站能够找到同时满足多PCIe接口以及高容量的准系统主机，且可以利旧我之前在 :ref:`hpe_dl380_gen9` 投资的大量ECC DDR4内存
- 要达到品牌工作站同样的容量、性能和扩展性，实际上组装主机的成本极高，甚至超过品牌工作站且无法保证稳定性和集成性

我最终选择了 :ref:`dell_t5820` 作为我的机器学习和LLM工作站:

- 通过主机提供的多PCIe接口以及扩展，加上品牌工作站950W容量电源，理论上可以支持 **双** :ref:`amd_mi50` 和 **双** :ref:`tesla_a2` 同时工作
- (放弃，实际发现没有官方资料显示支持，论坛上的讨论无疾而终)通过主板集成的 :ref:`pcie_bifurcation` 功能将单个PCIe插槽拆分为支持4块 :ref:`kioxia_exceria_g2` ，以便能够实践RDMA、NVMe  over TCP等存储技术

最终构想
----------

- :ref:`nasse_c246` 兼容主机:

.. literalinclude:: think_machine/c246
   :caption: 构想中的兼容机安装GPU的连接

- :ref:`dell_t5820` :

.. literalinclude:: think_machine/t5820
   :caption: 构想中的T5820安装GPU的连接
