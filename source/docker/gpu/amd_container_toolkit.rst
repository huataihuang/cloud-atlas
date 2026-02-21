.. _amd_container_toolkit:

=============================
AMD Container Toolkit
=============================

概述
======

和 :ref:`nvidia_container_toolkit` 类似，AMD Container Toolkit是一个结合容器化应用来使用AMD Instinct GPU的鲁棒和可伸缩的框架:

- 简化了在容器环境访问GPU，增强了设备发现以及更好集成到现代容器技术
- 这个toolkit被设计成与 :ref:`rocm` 软件堆栈无缝集成工作，允许开发者在高性能计算、机器学习和其他GPU加速负载中充分发挥AMD GPU能力
- AMD Container Toolkit架构直接集成在 :ref:`docker` daemon中来无缝管理GPU资源

这个AMD Container Toolkit有2个主要组件:

- ``amd-container-runtime`` : 一个定制的 :ref:`container_runtimes` (包装了 ``runc`` ) 来将AMD GPUs注入容器
- ``amd-ctk`` (Container Toolkit CLI): 管理GPU配置，运行时设置以及容器编排集成的命令行工具

:ref:`container_direct_access_amd_gpu` vs. AMD Container Toolkit
--------------------------------------------------------------------



参考
=========

- `AMD Container Toolkit Documentation <https://instinct.docs.amd.com/projects/container-toolkit/en/latest/index.html>`_
