.. _tesla_a2_wddm:

=======================================================
Tesla A2 WDDM (Windows Display Driver Model)图形模式
=======================================================

我为了能够在 :ref:`dell_t5820` 上使用面向数据中心的计算卡，尝试了各种 :ref:`dell_t5820_gpu` 方法，但是在 :ref:`tesla_a2_display_mode_switch` 失败之后，偶然google到 **NVIDIA Tesla A2要激活WDDM (Windows Display Driver Model)图形模式需要一个NVIDIA vGPU/GRID license** 。这又给了我一个在T5820上使用 :ref:`tesla_a2` 的方向，所以我想在适当时机下进行尝试。

.. warning::

   由于我的Dell T5820目前硬件故障，还没有修复，所以我准备在后续恰当的时机再做本文尝试。这里先整理一些资料，挖坑待后续实践!

方案
========

由于 Tesla 系列卡（A2、P4、P10、A100 等）在 NVIDIA 的产品线中定位为数据中心计算卡，NVIDIA 在驱动层对它们做了严格的限制： **默认仅开启 TCC (Tesla Compute Cluster) 模式以供 CUDA 计算，若要开启 WDDM 模式用于 DirectX/OpenGL 图形渲染，必须依赖 NVIDIA vGPU/vWS (Virtual Workstation) 许可证。**


WDDM
-----------

- **TCC 模式** : 显卡被视作纯计算设备，Windows 的 DWM（桌面窗口管理器）、DirectX（游戏/MSFS）和 OpenGL/Vulkan（Blender/Fusion 360）无法识别该显卡。
- **WDDM 模式** : 显卡被认作标准的图形输出设备，开启全套 3D 硬件加速和 DX11/DX12 支持。

.. note::

   由于 :ref:`dell_t5820` 特殊的工作站定位，Dell强制只能使用标准的图形输出设备。之前在使用 :ref:`amd_mi50` 数据中心计算卡时，也是通过 :ref:`amd_mi50_flash_vbios` 改成 Pro V420 才能够正常识别开机。


