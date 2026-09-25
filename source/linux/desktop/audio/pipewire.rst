.. _pipewire:

==============================
PipeWire音频系统
==============================

PipeWire是一个Linux平台增强音频和视频的项目，提供了低延迟，在音频和视频设备上基于图(graph-based)处理引擎来支持当前由 :ref:`pulseaudio` 和 JACK处理的案例。PipeWire设计成一个安全地与音频和视频设备交互的模型，以便能够被容器化应用使用，并且支持 :ref:`flatpak` 应用也是它的主要目标。

- 极低延迟地捕获和回放音频和视频
- 实时多媒体处理音频和视频
- 多处理器架构允许应用共享多媒体内容
- 无缝支持 :ref:`pulseaudio` , JACK, :ref:`alsa` 和 GStreamer 应用
- 支持沙箱应用，具体参考 :ref:`flatpak`

参考
======

- `Raspberry Pi OS Now Uses Wayland & PipeWire <https://www.omglinux.com/raspberry-pi-os-bookworm/>`_
- `PipeWire官网 <https://www.pipewire.org>`_
