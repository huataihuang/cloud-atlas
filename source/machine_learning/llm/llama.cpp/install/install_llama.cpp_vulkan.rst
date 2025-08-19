.. _install_llama.cpp_vulkan:

========================
Vulkan架构安装LLaMA.cpp
========================

Vulkan支持
===========

- :ref:`pi_4` 和 :ref:`pi_5` 支持Vulkan 1.2
- :ref:`intel_uhd_graphics_630` 支持Vulkan 1.3

有没有可能使用最基本的GPU功能来实现小型LLM推理?

.. note::

   `Performance of llama.cpp with Vulkan <https://github.com/ggml-org/llama.cpp/discussions/10879>`_ 可以看到，即使是非常古老的 ``Intel i5-8350U`` 也能够使用 Vulkan 支持来运行 Llama ，虽然性能是可怜的 ``3.23`` **tg128 t/s** ，大约是最新的 AMD Radeon RX 7900 XTX 的 ``1/50`` 。

   不过，既然有这个功能，我还是准备挑战一下，尝试在我购买的二手 :ref:`xeon_e-2274g` 构建和运行，看看能否运行

理论上 :ref:`llama` 是支持 :ref:`vulkan` 加速的，我考虑尝试一下在 :ref:`pi_5` 构建一个微型推理系统

.. literalinclude:: install_llama.cpp_vulkan/install_vulkan
   :caption: 在树莓派上安装 ``vulkan``

然后运行 ``vkcube`` 命令查看是否工作

待实践...

参考
====

- `Issues with running Llama.cpp on Raspberry Pi 5 with Vulkan. #5237 <https://github.com/ggml-org/llama.cpp/issues/5237>`_
- `Getting started with Vulkan on RPi? <https://forums.raspberrypi.com/viewtopic.php?t=344202>`_
- `How do i install Vulkan drivers? <https://www.reddit.com/r/raspberry_pi/comments/18uw25h/how_do_i_install_vulkan_drivers/>`_ 提供了安装vulkan驱动的信息
- `Llama.cpp supports Vulkan. why doesn't Ollama? <https://news.ycombinator.com/item?id=42886680>`_
- `Performance of llama.cpp with Vulkan <https://github.com/ggml-org/llama.cpp/discussions/10879>`_ 不同GPU的Vulkan性能评分列表
