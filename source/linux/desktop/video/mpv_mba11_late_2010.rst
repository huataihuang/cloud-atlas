.. _mpv_mba11_late_2010:

==================================
MacBook Air 11" Late 2010运行mpv
==================================

:ref:`mba11_late_2010` 硬件配置较弱:

- **Intel Core 2 Duo 处理器**
- **NVIDIA GeForce 320M 集成显卡**

古早的硬件需要优化才能流畅播放 ``1024x768`` x264/AC3 视频: **最大化利用 NVIDIA 的 VDPAU 硬件解码，并把渲染负担降到最低**

硬件解码与渲染核心参数说明
============================

- **硬件解码** ( ``hwdec=vdpau`` ): GeForce 320M 支持 NVIDIA 的 **VDPAU** 硬件解码（ ``PureVideo HD Gen4`` ），能完美硬解 x264/H.264 ``1024x768`` 视频，将 CPU 占用率从 ``80%+`` 降至 ``10%`` 左右。
- **Wayland 图形输出** ( ``vo=gpu`` + ``gpu-context=wayland`` ): Sway 是纯 :ref:`wayland` 窗口管理器，必须让 mpv 直接接入 Wayland 合成器，避免 Xwayland 带来的额外开销。
- **音频输出** ( ``ao=pipewire`` 或 ``ao=alsa`` ):取决于系统使用的是 PipeWire 还是原生 ALSA。

- ``~/.config/mpv/mpv.conf`` :

.. literalinclude:: mpv_mba11_late_2010/mpv.conf
   :caption: 针对 :ref:`mba11_late_2010` 优化的 ``mpv.conf``

- 要让 VDPAU 硬件解码在 Alpine / Sway 下正常工作，确保宿主机安装了 NVIDIA 驱动对应的 VDPAU 库:

.. literalinclude:: mpv_mba11_late_2010/apk_add
   :caption: 安装VDPAU库

在开源 ``Nouveau`` 驱动下，

注意早期是安装 ``libvdpau`` 和 ``mesa-vdpau-gallium`` 才能让VDPAU硬件解码正常工作。这是因为Nouveau驱动本身是Linux内核级的DRM模块，具体的VDPAU硬件解码接口实现是由Mesa项目中Gallium3D VDPAU状态跟踪器( ``mesa-vdpau-gallium`` )提供的。

不过，现在已经替换成 ``mesa-va-gallium`` : Mesa提供给Nouveau开源驱动的VA-API硬件加速实现

``libva-vdpau-driver`` 是 VA-API 与 VDPAU 之间的桥梁转换库(使得支持VDAPU的应用可以通过VA-API调用Nouveau硬件解码器)

- 安装 ``vainfo`` 工具来检测 Nouveau的硬件解码器支持情况:

.. literalinclude:: mpv_mba11_late_2010/libva-utils
   :caption: 安装 ``libva-utils`` 来获得 ``vainfo``

- 运行 ``vainfo`` 输出显示:

.. literalinclude:: mpv_mba11_late_2010/vainfo_output
   :caption: ``vainfo`` 输出状态
   :emphasize-lines: 7,9

注意，这里输出信息:

- ``Driver version: Mesa Gallium driver 26.1.6 for NVAF`` 表示Mesa的 ``mesa-va-gallium`` 驱动已经认出了 ``NVAF`` (GeForce 320M)芯片组
- ``VAProfileNone`` 行缺少了 ``VAEntrypointVLD`` : 这意味着Mesa驱动现在只暴露了视频后处理(Video Processing)接口，但没有将硬件解码器(VP4 Engine)挂载上。

这个现象主要有2个原因:

- 缺少固件(Firmware): Nouveau的VP4解码器需要外部的芯片固件才能初始化硬解引擎
- Mesa编译策略或环境设置: 在较新的Mesa 26.1+下，Nouveau开源驱动默认关闭了老旧的NV50/NVAF硬件的纯硬件视频解码功能

我检查了我的系统，发现已经安装了 ``linux-firmware-nvidia`` 这个固件，这说明实际上是Nouveau驱动已经不再支持老旧NVAF硬件解码功能。

所以 ``mpv.conf`` 配置文件应该设置成 ``hwdec=auto-safe`` 这样在无法硬解时平滑切换至CPU解码。

.. literalinclude:: mpv_mba11_late_2010/mpv_softdec.conf
   :caption: 修订为软解的优化配置

参考
======

- gemini
