.. _intro_selkies:

======================
Selkies简介
======================

Selkies-GStreamer 是一款开源的低延迟、高性能的 Linux 原生 GPU/CPU 加速 ``WebRTC`` **HTML5**  远程桌面流媒体平台，支持自托管、容器、Kubernetes 或云/高性能计算平台。

在传统的 Docker 镜像中，如果想在浏览器里运行一个带图形界面（GUI）的 Linux 软件，早期的标配方案是 Apache :ref:`guacamole` + VNC (X11vnc/TigerVNC) + NoVNC。但是VNC协议非常古老，本质上是通过定时抓取屏幕位图变化进行传输。这就导致在浏览器中操作时延迟极高、鼠标漂移、画质糊且极度消耗CPU算力。

为了解决这个问题，由 Google 工程师以及开源社区共同发起了基于 :ref:`Kubernetes` 和云原生架构的Selkies平台。核心思想上: **不再把桌面当成“图片”传输，而是把整个 Linux 桌面当成一场“实时视频直播”或“云游戏”来打通链路** :

- WebRTC 协议：Selkies 底层完全基于 WebRTC（就是网页版视频会议、微信视频通话用的底层技术）。它建立了浏览器与容器之间的双向原生 P2P 管道。
- 硬件/软件 H.264 压缩：它直接捕获 X11 或 Wayland 虚拟显示器的画面，在容器内部利用 FFmpeg（甚至能调用服务器上的 :ref:`tesla_p10` / :ref:`tesla_a2` NVENC 硬件加速）实时压缩成 H.264 视频流。
- 极致性能：Selkies 可以做到音频和视频同步、支持 60 帧动态刷新、支持远程剪贴板的高级双向映射，甚至能用来在浏览器里玩 Linux 3D 游戏。

.. note::

   :ref:`linuxserver_docker-calibre` 打包了Selkies来实现Linux桌面运行Calibre应用:

   - 应用层：原生的 Linux 版 calibre 图形软件，它将自己的画面输出到虚拟显卡（Xvfb）
   - 流媒体层（Selkies 面板）：Selkies 的后台守护进程实时捕捉这个虚拟显卡的画面，将其通过 WebRTC 协议打包装箱，最终通过容器的 ``8080`` 端口输出一个非常精致的、带侧边栏控制面板的 HTML5 前端页面。

参考
=======

- `What is Selkies? <https://selkies-project.github.io/selkies/design/>`_
- gemini
