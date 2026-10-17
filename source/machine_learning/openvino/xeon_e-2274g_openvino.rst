.. _xeon_e-2274g_openvino:

================================
Intel Xeon E-2274G环境OpenVINO
================================

.. note::

   本文和gemini进行讨论后整理

:ref:`xeon_e-2274g` (Coffee Lake 架构，第 8 代) 与 :ref:`xeon_w-2235` ( :ref:`xeon_w-2225_openvino` Cascade Lake 架构，第 10 代) 在底层架构、性能定位以及指令集扩展上有很大差异:

.. csv-table:: Intel Xeon E-2274G vs. W-2235
   :file: xeon_e-2274g_openvino/e-2274g_vs_w-2235.csv
   :widths: 10,30,30,30
   :header-rows: 1

分析
======

OpenVINO 能够完全兼容并运行在 :ref:`xeon_e-2274g` 和 :ref:`xeon_w-2235` ，但 **加速原理和性能表现截然不同** :

- :ref:`dell_t5820` 上的 :ref:`xeon_w-2235` (CPU 纯算力推理极佳)

  - **指令集优势(DL Boost / VNNI)** : Cascade Lake 架构首次引入了 ``Vector Neural Network Instructions(VNNI)`` 
