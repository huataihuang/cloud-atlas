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

从技术参数来看，Intel UHD Graphics 630似乎只有 :ref:`tesla_p10` 的 ``1/30`` 性能，具体待实测

机器学习
=========

`llama.cpp for SYCL <https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md>`_ 说明了 ``SYCL`` 后端支持是通过 Intel oneAPI 实现，所以需要查询 `Intel® oneAPI Base Toolkit System Requirements <https://www.intel.com/content/www/us/en/developer/articles/system-requirements/oneapi-base-toolkit/2025.html#inpage-nav-1-1>`_ :

- Intel UHD Graphics 必须是 ``第11代处理器`` 或更新版本集成的显卡
- Intel Iris Xe graphics
- Intel Arc graphics
- ...

对于 :ref:`ollama` 支持Intel GPU是通过 :ref:`ipex-llm` 来实现的，同样 ``ipx-llm`` 文档 `在带有 Intel GPU 的 Windows 系统上安装 IPEX-LLM <https://github.com/intel/ipex-llm/blob/main/docs/mddocs/Quickstart/install_windows_gpu.zh-CN.md>`_ 可以看到需要 " Intel Core Ultra 和 Core 11-14 代集成的 GPUs (iGPUs)，以及 Intel Arc 系列 GPU"

很不幸，我的 :ref:`xeon_e-2274g` 集成的 ``Intel UHD Graphics 630`` 不在支持之列，也就是说无缘 :ref:`llama` 支持了，哭... (安慰自己一下，毕竟十一代之后的CPU价格较贵，我现在使用的九代CPU也算物尽其用 ^_^ )

不过，也不是完全绝望:

- `Supported APIs for Intel® Graphics <https://www.intel.com/content/www/us/en/support/articles/000005524/graphics.html>`_ 显示Intel UHD 630支持 vulkan 1.3
- `llama build: Vulkan <https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#vulkan>`_ 显示llama可以通过Vulkan API来使用GPU，也就变相支持了旧版本 ``Intel UHD Graphics``

我准备以vulkan的思路来尝试驱动 ``Intel UHD Graphics 630`` 用于llama: 配置20GB的共享显存，这样可以加载 :ref:`ollama_run_deepseek` 32b模型进行推理，正好能够对应 :ref:`tesla_p10` 的24GB显存同样使用32b模型。很期待两者的性能对比...

Intel显卡的DVMT技术
======================

Intel内置显卡的内存是动态分配的，也就是操作系统系统内存分配给显卡使用，在BIOS中设置称为 ``DVMT`` (Dynamic Video Memory Technoloy)。不过，实际上这个值在BIOS中只能设置 ``128MB`` , ``256MB`` 和 ``maximum`` ，而其他设置值取决于主板制造商和安装在主机的内存量。

``DVMT`` 的资料似乎比较匮乏，Intel网站 `How to Adjust Dedicated Video Memory for Intel Graphics <https://www.intel.com/content/www/us/en/support/articles/000041253/graphics.html>`_ 没有明确说明，只提供了一个Windows 10/11的配置指引，看起来是操作系统动态配置的: `Frequently Asked Questions for Intel® Graphics Memory on Windows® 10 and Windows 11 <https://www.intel.com/content/www/us/en/support/articles/000020962/graphics.html>`_ :

The amount of graphics memory in use is dynamically allocated to balance the needs of the operating system and all running applications.

在Windows系统上 ``Intel UHD Graphics`` 630 最多可以分配一半的系统内存作为显卡显存。

目前我还没有找到有关Linux的配置方法，有些资料可能可以参考:

- `Intel UHD Graphics 630 "Coffee Lake" On Linux <https://www.phoronix.com/review/coffee-uhd-graphics>`_
- `Don't Change DVMT Pre-allocated Video Memory in BIOS. Lessens Performance. <https://www.reddit.com/r/gpdwin/comments/5hxgpe/dont_change_dvmt_preallocated_video_memory_in/>`_
- `Windows: Calculating Graphics Memory <https://learn.microsoft.com/en-us/windows-hardware/drivers/display/calculating-graphics-memory>`_

参考
======

- `Support for Intel® UHD Graphics 630 <https://www.intel.com/content/www/us/en/support/products/126790/graphics/processor-graphics/intel-uhd-graphics-family/intel-uhd-graphics-630.html>`_ Intel官方UHD Graphics 630支持页面，包括文档和驱动等
- `Intel UHD Graphics 630 Specs <https://www.techpowerup.com/gpu-specs/uhd-graphics-630.c3107>`_
