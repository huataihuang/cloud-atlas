.. _install_llama.cpp_arm_kleidiai:

===============================
Arm KleidiAI架构安装Llama.cpp
===============================

``KleidiAI`` 是Arm处理器设计的优化AI工作负载的微架构软件库，可以增强使用Arm处理器后端的性能。llama.cpp支持编译 KleidiAI 优化:

.. literalinclude:: install_llama.cpp_arm_kleidiai/build
   :caption: 使用 Arm CPU优化 ``-DGGML_CPU_KLEIDIAI=ON``

然后运行时验证是否支持了 KleidiAI:

.. literalinclude:: install_llama.cpp_arm_kleidiai/run
   :caption: 验证 Arm CPU优化

KleidiAI微内核使用Arm CPU功能，如dotprod, int8mm 和 SME来优化tensor操作，此时llama.cpp会在检测到运行时CPU功能时选择更为高效的内核。不过，对于支持 SME 的平台，必须手工激活 SME 微内核，也就是设置环境变量 ``GGML_KLEIDIAI_SME=1`` 。

需要注意，如果有更为高优先级的后端，则更高优先级的后端会默认激活。比如METAL后端，需要使用 ``-DGGML_METAL=OFF`` 来编译才能确保使用CPU后端，或者在运行时使用 ``--device none`` 选项来使用Arm CPU。 

.. note::

   我不太确定Arm处理器需要在哪个架构硬件能够支持 KleidiAI ，先挖坑待后续调研和实践

   :ref:`pi_5` ?

参考
======

- `Hugging Face: Arm <https://huggingface.co/Arm>`_
- `Arm Kleidi官方宣传资料 <https://www.arm.com/markets/artificial-intelligence/software/kleidi>`_
- `Arm Kleidi Libraries官方资料 <https://www.arm.com/products/development-tools/embedded-and-software/kleidi-libraries>`_
