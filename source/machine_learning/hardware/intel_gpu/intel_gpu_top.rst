.. _intel_gpu_top:

=====================
intel_gpu_top
=====================

安装
=======

.. literalinclude:: intel_gpu_top/install
   :caption: 安装intel-gpu-tools

``intel_gpu_top`` 是一个实时类似top的Intel GPU使用率，引擎使用情况，时钟速度以及内存度量工具。

硬件环境
=========

我的 :ref:`xeon_e-2274g` 提供了一个内置的 Intel UHD Graphics P630 (Coffee Lake架构核显)，所以可以采用类似 :ref:`optimize_nvidia_gpu_fan_control` 压测观察是用 ffmpeg 来观察 Intel 的 VAAPI / QuickSync 编码引擎。

- 确认核显渲染节点与权限

在 Linux 下，Intel 核显的硬件加速通常通过 Direct Rendering Manager (DRM) 节点访问

.. literalinclude:: intel_gpu_top/dri
   :caption: 检查核显设备节点

输出显示

.. literalinclude:: intel_gpu_top/dri_output
   :caption: 检查核显设备节点

输出显示有4个显卡，因为我的 :ref:`nasse_c246` 安装了3块 :ref:`tesla_a2` ，加上 :ref:`xeon_e-2274g` 内置的 Intel UHD Graphics P630，所以需要能区分出来进行测试。

分辨的方式是通过 ``/dev/dri/by-path/`` 来观察，Intel 核显（Coffee Lake 平台）的 PCI 地址固定是 ``0000:00:02.0`` （内部总线 ``00:`` ）

.. literalinclude:: intel_gpu_top/dri_by-path
   :caption: 检查 ``/dev/dri/by-path/``

输出显示:

.. literalinclude:: intel_gpu_top/dri_by-path_output
   :caption: 检查 ``/dev/dri/by-path/``
   :emphasize-lines: 2,3

这也可以通过 ``lspci | grep -i p630`` 可以看到 ``00:02.0`` 对应的就是 ``Intel UHD Graphics P630`` :

.. literalinclude:: intel_gpu_top/lspci
   :caption: 检查lspci中Intel显卡

另外， ``udevadm`` 能够直接查询设备驱动信息，更为严谨:

.. literalinclude:: intel_gpu_top/udevadm
   :caption: 通过 ``udevadm`` 检查设备驱动

输出中显示包含 ``DRIVERS=="i915"`` 或 ``DRIVERS=="xe"`` ，且 Vender ID是 ``0x8086`` (Intel厂商代码)，那么这个节点(如 ``renderD131`` )就是Intel核显:

.. literalinclude:: intel_gpu_top/udevadm_output
   :caption: 通过 ``udevadm`` 检查设备驱动
   :emphasize-lines: 1,2

压测
=======

- 准备工作: 为Intel显卡安装 **VAAPI 驱动库** 

.. literalinclude:: intel_gpu_top/intel_vaapi
   :caption: 针对 Intel 核显的 VAAPI 驱动库

因为ffmpeg测试使用了 ``h264_vaapi`` 格式，并且寻求 ``-hwaccel vaapi`` 来压测，所以需要系统安装Intel 核显的现代 VAAPI 驱动，否则执行会报错

.. literalinclude:: intel_gpu_top/vaapi_error
   :caption: 测试命令出现vaapi相关错误

- 用 ``vainfo`` 验证 ``/dev/dri/renderD131`` 是否可用:

.. literalinclude:: intel_gpu_top/vainfo
   :caption: 检查设备驱动是否响应

注意，这里如果不是 ``root`` 用户或者 ``sudo`` ，那么会出现报错 ``Failed to open the given device!`` ，执行以下命令将自己加入 ``render`` 组:

.. literalinclude:: intel_gpu_top/usermod
   :caption: 将当前用户加入render组

如果正常则会看到:

.. literalinclude:: intel_gpu_top/vainfo_output
   :caption: 正常的话显示Driver version: Intel iHD driver...
   :emphasize-lines: 7

- 执行压测:

.. literalinclude:: intel_gpu_top/ffmpeg
   :caption: 执行ffmpeg压测

``-global_quality 25`` 在 VAAPI 的 CQP（常数质量）模式下，通过指定全局画质参数（数值通常在 20~30 之间，越小画质越高、运算量越大）来驱动编码器高负荷运转。这里没有使用 ``-b:v 50M`` 参数，是因为Intel 核显的 VAAPI 驱动在当前的配置下，只支持 CQP（恒定量化参数，即固定画质模式）。

压测时可以看到 ``intel_gpu_top`` 显示信息:

.. literalinclude:: intel_gpu_top/top_output
   :caption: ``intel_gpu_top`` 显示

此时观察 ``intel_gpu_top`` 可以看到 ``Video`` 引擎负载，并且使用 ``sensors`` 命令可以看到CPU核心温度升高。

参考
======

- `ubuntu Manpages: intel_gpu_top <https://manpages.ubuntu.com/manpages/trusty/man1/intel_gpu_top.1.html>`_
- `debian General Commands Manual: intel_gpu_top(1) <https://manpages.debian.org/testing/intel-gpu-tools/intel_gpu_top.1.en.html>`_
