.. _firefox_gpu_acculate:

=========================================
Firefox 硬件加速
=========================================

Firefox 在 BSD/Linux 上的硬件加速分为 WebRender（渲染加速）和 VA-API（视频解码加速）(请参考 :ref:`freebsd_sway_intel-driver` )

检查是否开启硬件加速
=====================

在 Firefox 地址栏输入 ``about:support`` 并回车:

- 找到 ``Graphics`` (图形) 部分:

  - ``Compositing`` 如果显示 ``WebRender`` 说明窗口渲染已经实现硬件加速。如果显示 ``WebRender(Software)`` 则表明是CPU软件渲染(未开启硬件加速)
  - ``Window Protocol`` 必须显示 ``wayland`` (对于 :ref:`sway` )。如果显示 ``xwayland`` ，则需要在环境变量中设置 ``MOZ_ENABLE_WAYLAND=1`` 来运行Firefox

- 搜索 ``HARDWARE_VIDEO_DECODING`` 如果显示 ``available by default`` ，则说明Firefox理论上使用显卡硬件加速来播放视频

强制开启硬件加速
==================

如果 ``about:support`` 里面显示被屏蔽，则可以手工开启硬件加速:

- 访问 ``about:config`` :
- 搜索并设置:

  - ``gfx.webrender.all`` -> ``true``
  - ``media.ffmpeg.vaapi.enabled`` -> ``true``

- 重启Firefox
