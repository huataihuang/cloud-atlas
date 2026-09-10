.. _alpine_moonlight_mba11_late_2010:

=====================================================
MacBook Air 11" Late 2010运行Alpine Linux的moonlight
=====================================================

运行 ``moonlight-embedded`` 串流，在 :ref:`mba11_late_2010` 上只支持 H.264 ，其显卡核心 NVIDIA GeForce 320M 具备 **H.264 硬件解码** 功能，但是在 :ref:`alpine_linux` 只能使用开源 ``nouveau`` 驱动。

.. note::

   2010 款 MacBook Air (GeForce 320M / MCP89)硬件非常古老，当前只能使用开源 ``nouveau`` 驱动:

   - 不支持现代 Linux 内核:

     - GeForce 320M 属于 NVIDIA 的 Tesla 架构 (NV50 家族)。NVIDIA 对该架构显卡支持的最后一版官方驱动是 304.xx 系列（于 2017 年彻底停止维护）
     - NVIDIA 304.xx 驱动仅支持到 Linux Kernel 4.x（极极限下依靠社区补丁勉强能补到 5.4 左右）

   - 完全不支持 Wayland / Sway:

     - NVIDIA 304.xx 驱动发布时，Wayland 规范尚处于早期萌芽阶段。它不支持 KMS (Kernel Mode Setting)，更不支持 GBM (Generic Buffer Management) 或 EGLStreams
     - Sway 彻底无法在 NVIDIA 304.xx 私有驱动上运行，即使强行安装成功，也只能使用传统的 X11 桌面（如 XFCE / Openbox）

   - VDPAU 与现代视频播放器脱节:

     - NVIDIA 私有驱动的视频硬解使用的是 VDPAU 接口，而不是 VA-API: 在现代 Wayland 环境下，VDPAU 到 Wayland 的转译层效率极低且兼容性极差

为了能够充分发挥 :ref:`mba11_late_2010` 硬件性能，我选择了最轻量级的 Alpine+Sway+Nouveau 架构:

- 能够运行现代 Wayland 桌面的最轻量、最高效的组合
- ``mesa-va-gallium`` 提供了VA-API 硬件解码

  - 如果 Nouveau 的 VA-API 硬解不稳定（出现花屏或崩溃）: 则尝试将 ``moonlight-embedded`` 的串流分辨率限制为 720p @ 60fps 或 1080p @ 30fps，并使用 CPU 软解
  - :ref:`mba11_late_2010` 11 英寸的小屏幕上，720p 的清晰度已经非常出色，且这颗双核 CPU 纯软解 720p 的压力和延迟都在完全可接受的范围内

参考
======

- gemini
