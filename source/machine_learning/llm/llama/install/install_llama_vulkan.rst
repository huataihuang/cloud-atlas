.. _install_llama_vulkan:

========================
Vulkan架构安装LLaMA
========================

:ref:`pi_4` 和 :ref:`pi_5` 支持Vulkan 1.2，有没有可能使用最基本的GPU功能来实现小型LLM推理?

理论上 :ref:`llama` 是支持Vulkan加速的，我考虑尝试一下在 :ref:`pi_5` 构建一个微型推理系统

.. literalinclude:: install_llama_vulkan/install_vulkan
   :caption: 在树莓派上安装 ``vulkan``

然后运行 ``vkcube`` 命令查看是否工作

待实践...

参考
====

- `Issues with running Llama.cpp on Raspberry Pi 5 with Vulkan. #5237 <https://github.com/ggml-org/llama.cpp/issues/5237>`_
- `Getting started with Vulkan on RPi? <https://forums.raspberrypi.com/viewtopic.php?t=344202>`_
- `How do i install Vulkan drivers? <https://www.reddit.com/r/raspberry_pi/comments/18uw25h/how_do_i_install_vulkan_drivers/>`_
