.. _freebsd_sway_intel-driver:

=================================
FreeBSD使用Intel显卡的Sway环境
=================================

我现在在 :ref:`thinkpad_x220` 笔记本上运行FreeBSD 15: 笔记本使用Intel内置的GPU，所以需要针对Intel显卡进行Sway适配

Sway环境初始化
================

- 默认在 :ref:`freebsd_sway` 部署时已经完成如下安装步骤

Intel显卡VA-API库
===================

为了加速 :ref:`mpv` 适配播放不卡顿且不占用过高CPU，需要配置 **显卡硬件加速(VA-API)**

- 早期Intel显卡(集成显卡)，即Intel CPU第7代及更早，例如我的 :ref:`thinkpad_x220` 使用Intel Core i5-2410M Processor是第二代Sandy Bridge，安装 ``libva-intel-driver`` 

.. literalinclude:: freebsd_sway_intel-driver/install_libva-intel-driver
   :caption: 安装 ``libva-intel-driver``

对于较新的Intel CPU（第 8 代以后），建议安装 ``libva-intel-media-driver``

验证
------

- 安装 ``libva-utils`` 软件包，并运行 ``vainfo`` :

.. literalinclude:: freebsd_sway_intel-driver/vainfo
   :caption: 安装 ``libva-utils`` 运行 ``vainfo``

在没有安装 ``libva-intel-driver`` 之前， ``vainfo`` 显示缺乏驱动报错: 

.. literalinclude:: freebsd_sway_intel-driver/vainfo_output
   :caption: 运行 ``vainfo`` 显示缺乏驱动

安装了 ``libva-intel-driver`` 之后， ``vainfo`` 就正确显示了支持度驱动版本:

.. literalinclude:: freebsd_sway_intel-driver/vainfo_intel_output
   :caption: 运行 ``vainfo`` 显示支持的Intel显卡

注意，上述显示信息中:

- ``libva info: va_openDriver() returns 0`` 表明驱动加载成功
- ``VAProfileH264High : VAEntrypointVLD`` 表明显卡支持H.264视频硬件解码
- ``wl_drm_interface`` 是Wayland 下 DRM（直接渲染管理器）的一个旧接口，较新的 Wayland 合成器（如 Sway 使用的 wlroots）和 Mesa 库正在逐步淘汰这个接口，转而使用更现代的 linux-dmabuf 协议来传输数据

  - 由于我的 i5-2410M 属于第二代酷睿，使用的是 i965 驱动。这个驱动在尝试通过旧的 DRM 方式与 Wayland 通讯时找不到对应的符号
  - 这个报错可以忽略。因为报错后，VA-API 会自动尝试其他路径，最终成功打开了驱动

.. note::

   由于 i5-2410M 是一款 2011 年的处理器，仅支持 H.264 (AVC)、MPEG2、VC-1， 不支持 HEVC (H.265)、VP9、AV1。所以为了避免YouTube上观看4K视频（通常是 VP9 或 AV1 编码），可以在FireFox中安装 ``enhanced-h264ify`` 强制YouTube 只提供 H.264 格式的视频

应用的显卡硬件加速
===========================

- :ref:`mpv_intel_gpu`
