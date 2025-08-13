.. _ollama_amd_gpu:

===============================
Ollama使用AMD GPU运行大模型
===============================

安装ROCm
===========

.. note::

   之前尝试在 :ref:`amd_firepro_s7150x2` 尝试部署AMD ROCm软件堆栈来支持运行不同的LLM ，但是因为硬件支持兼容性原因失败。好在我又购买了较新的 :ref:`amd_radeon_instinct_mi50` 完成 :ref:`rocm_quickstart` ，现在可以支持使用 ``Ollama`` 。部署环境是在  :ref:`bhyve_amd_gpu_passthru` 实现。

:ref:`amd_gpu` 部署 ``Ollama`` 除了需要安装 ``ollama-linux-amd64.tgz`` 包以外(也就是 :ref:`nvidia_gpu` 是内置支持)，还需要附加安装 ``ollama-linux-amd64-rocm.tgz``

- 首先和 :ref:`intro_ollama` 一样下载 ``ollama-linux-amd64.tgz`` 安装 ``ollama`` 执行程序:

.. literalinclude:: install_ollama/install_manual
   :caption: 手工本地安装

- 安装 ROCm 和 AMDGPU驱动( :ref:`rocm_quickstart` )

.. literalinclude:: ../../hardware/amd_gpu/rocm/rocm_quickstart/ubuntu_24.04_install
   :caption: 在 Ubuntu 24.04 上安装 ROCm

.. literalinclude:: ../../hardware/amd_gpu/rocm/rocm_quickstart/amdgpu_driver_install
   :caption: Ubuntu 24.04 安装 amdgpu 驱动

- 比 :ref:`ollama_nvidia_gpu` 多一个步骤，需要附加安装 ``ollama-linux-amd64-rocm.tgz`` :

.. literalinclude:: ollama_amd_gpu/ollama_rocm
   :caption: 安装 ``ollama-linux-amd64-rocm``

检查就可以看到实际上安装目录就是 ``/usr/lib/ollama/rocm`` ，检查就可以看到 ``/usr/lib/ollama`` 目录下也包含了 ``cuda_v11`` 和 ``cuda_v12`` 以及一些cpu相关的运行动态库文件，为了节约根目录空间，可以移动到大容量磁盘中:

.. literalinclude:: ollama_amd_gpu/ollama_lib
   :caption: 将 ``/usr/lib/ollama`` 移动到大容量硬盘内

配置
========

和 :ref:`ollama_nvidia_gpu` 配置类似，但又有所不同。按照官方文档，Ollama通过AMD ROCm库来使用AMD GPU，并不是直接支持所有AMD GPU。需要传递一个 LLVM target，而这个LLVM target是一个需要将GPU和 LLVM target 对应起来的参数。

- HSA_OVERRIDE_GFX_VERSION

这个参数比较搞，参考 https://forum.level1techs.com/t/ubuntu-22-04-from-zero-to-70b-llama-with-both-nvidia-and-amd-7xxx-series-gpus/206411/13

:ref:`amd_firepro_s7150x2` 实践笔记
-------------------------------------

启动一次 ``ollama`` 然后查看日志:

.. literalinclude:: ollama_amd_gpu/ollama.log
   :caption: 查看ollama启动时发现的AMD GPU信息
   :emphasize-lines: 8-10

很不幸，我的这块 :ref:`amd_firepro_s7150x2` 检测显示为 ``gfx802`` ，不在支持之列(最低是 ``gfx900`` )，我尝试传递环境变量 ``HSA_OVERRIDE_GFX_VERSION=9.0.0`` (找最接近的LLVM版本)，但是很不幸，重启ollama依然报错(如果兼容正确，则应该能够看到报告显卡的显存大小)

.. literalinclude:: ollama_amd_gpu/ollama_err.log
   :caption: 修订环境变量但是查看ollama启动日志还是显示不支持
   :emphasize-lines: 7-9

.. warning::

   很不幸，我的 :ref:`amd_firepro_s7150x2` 太古老无法支持，所以 ``ollama`` 在AMD GPU上测试无法继续进行

对于支持的AMD GPU，还可以传递一个 ``ROCR_VISIBLE_DEVICES`` 来指定设备，这个参数的值是通过 ``rocminfo`` 获得的设备列表(不过我没有实践过)

补充信息
~~~~~~~~~

- `Gentoo提供了一个编译支持amdgpu_targets USE列表 <https://packages.gentoo.org/useflags/amdgpu_targets_gfx1030>`_ 看起来最低的支持是 ``gfx803`` (Fiji GPU, codename fiji, including Radeon R9 Nano/Fury/FuryX, Radeon Pro Duo, FirePro S9300x2, Radeon Instinct MI8) ，看来我的二手 :ref:`amd_firepro_s7150x2` 不在支持之列

- `Use ROCm on Redeon  GPUs > Compatibility metrices > Linux support matrices by ROCm version <https://rocm.docs.amd.com/projects/radeon/en/latest/docs/compatibility/native_linux/native_linux_compatibility.html>`_ :

  - 操作系统支持 Ubuntu 22.04 / 24.04
  - AMD Radeon系列最低看来是 AMD Radeon Pro W7800
  - :ref:`pytorch` 2.4.1/Stable 支持的 ROCm 版本最低是 6.1 ，但是不支持 Radeon 7000 系列

:ref:`amd_radeon_instinct_mi50` 实践笔记
---------------------------------------------

- 执行 ``ollama serve`` 命令，然后检查控制台输出:

.. literalinclude:: ollama_amd_gpu/ollama_serve_log
   :caption:  执行 ``ollama serve`` 终端输出
   :emphasize-lines: 4

看起来我的 :ref:`amd_radeon_instinct_mi50` 似乎不兼容？

