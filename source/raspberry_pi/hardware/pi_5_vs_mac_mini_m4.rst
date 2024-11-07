.. _pi_5_vs_mac_mini_m4:

===============================
树莓派5 vs. Mac mini M4(2024年)
===============================

说来你可能感到惊讶，树莓派这种廉价(其实也不算便宜)的SoC设备，居然想要和苹果入门级Mac mini一较长短?

其实，我是想比较一下，我正在一步步构建的 :ref:`pi_soft_storage_cluster` ，在累计投入了大量的资金(数千元)，能够接近或达到 :ref:`mac_mini_2024` 差距在哪里...

:ref:`pi_soft_storage_cluster` 硬件投入
========================================

.. csv-table:: 树莓派5集群硬件投入
   :file: pi_5_vs_mac_mini_m4/pi_5_cost.csv
   :widths: 40, 20, 20, 20
   :header-rows: 1

GeekBench ( ``不服跑个分`` )
===============================

.. warning::

   我没有实际测试过 ``树莓派5 vs. Mac mini M4(2024年)`` ，本文只是搜集资料对比硬件，以期获得感性的性能比较。

最直接比较性能的方式是采用相同性能测试工具对比硬件，本文采用了以下资料:

- `Geekbench Mac16,1 <https://browser.geekbench.com/v6/cpu/8690636>`_
- `Geekbench Raspberry Pi 5 <https://browser.geekbench.com/v5/cpu/22241537>`_

.. csv-table:: :ref:`pi_5` vs. :ref:`mac_mini_2024` 单核和多核
   :file: pi_5_vs_mac_mini_m4/geekbench_pi_5_vs_mac_mini_m4.csv
   :widths: 20, 30, 30, 20
   :header-rows: 1

性价比
=======

其实两者无法比较，但是我在这里提醒自己:

- 购买和运行3台 :ref:`pi_5` 将花费和 :ref:`mac_mini_2024` 几乎相同的经费

  - 综合 :ref:`pi_5` 集群的性能，大约是单台 :ref:`mac_mini_2024` **1/3**
  - **不过剔除树莓派大容量存储费用差异** 实际性价比大约是 ``花费了Mac mini 1/2 的金钱 获得了 1/3 的性能`` ，大约的收益比就是 ``2/3``
  - 当然设备的精密程度、硬件可靠性和稳定性，树莓派可能和Mac mini差距极大

- 玩树莓派的收益主要是开放系统，对 :ref:`linux` 操作系统以及相关的存储技术有更 "感性" 的认识(毕竟是 :ref:`kubernetes` 容器化运行)
- 不过，苹果的 :ref:`macos` 其实通过自身虚拟化、容器化，例如采用 :ref:`colima` 技术其实也可以完全做到树莓派上能够做的所有事情。只不过多了一层虚拟化，感觉稍微空灵一点

.. note::

   其实我非常希望能够拥有一台 :ref:`mac_mini_2024` ，希望能够折腾ARM架构的 :ref:`macos` ，体验完全不同的技术领域:

   - 我认为 :ref:`mac_mini_2024` 更值得购买
   - 但是树莓派开放性和硬件可玩性更容易让你融入 :ref:`linux` 的世界


