.. _intel_uhd_graphics_630:

==========================
Intel UHD Graphics 630
==========================

Intel UHD Graphics 630 是Intel于2017年9月1日推出的集成显卡解决方案，集成在14nm工艺的Coffee Lake处理器中。虽然和 :ref:`nvidia_gpu` / :ref:`amd_gpu` 无法相提并论，但是是提供了开箱即得的不错的图形功能，而且买CPU送GPU，所以性价比很高。

技术规格
============

.. csv-table:: Intel UHD Graphics 630 vs. Tesla P10
   :file: intel_uhd_graphics_630/630_spec.csv
   :widths: 20, 40, 40
   :header-rows: 1

从技术参数来看，Intel UHD Graphics 630似乎只有 :ref:`tesla_p10` 的 ``1/30`` 性能

机器学习
=========

`llama.cpp for SYCL <https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md>`_ 说明了 ``SYCL`` 后端支持是通过 Intel oneAPI 实现，所以需要查询 `Intel® oneAPI Base Toolkit System Requirements <https://www.intel.com/content/www/us/en/developer/articles/system-requirements/oneapi-base-toolkit/2025.html#inpage-nav-1-1>`_ :

- Intel UHD Graphics 必须是 ``第11代处理器`` 或更新版本集成的显卡
- Intel Iris Xe graphics
- Intel Arc graphics
- ...

很不幸，我的 :ref:`xeon_e-2274g` 集成的 ``Intel UHD Graphics 630`` 不在支持之列，也就是说无缘 :ref:`llama` 支持了，哭... (安慰自己一下，毕竟十一代之后的CPU价格较贵，我现在使用的九代CPU也算物尽其用 ^_^ )

参考
======

- `Support for Intel® UHD Graphics 630 <https://www.intel.com/content/www/us/en/support/products/126790/graphics/processor-graphics/intel-uhd-graphics-family/intel-uhd-graphics-630.html>`_ Intel官方UHD Graphics 630支持页面，包括文档和驱动等
- `Intel UHD Graphics 630 Specs <https://www.techpowerup.com/gpu-specs/uhd-graphics-630.c3107>`_
