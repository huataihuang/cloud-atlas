.. _mpv_intel_gpu:

==================================
MPV intel显卡优化
==================================

:ref:`freebsd_sway_intel-driver` 设置好系统的 **显卡硬件加速 (VA-API)** 之后，通过以下方式在mpv中开启硬件解码:

- 配置 ``~/.config/mpv/mpv.conf``

.. literalinclude:: mpv_intel_gpu/mpv.conf
   :caption: 设置mpv使用显卡硬件加速
