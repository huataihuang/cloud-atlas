.. _linuxserver_docker-calibre_gpu:

======================================
linuxserver/colibre使用GPU加速
======================================

在排查 :ref:`linuxserver_docker-calibre_http2_safari_cache` 意外发现，原来在容器内部运行的图形系统 :ref:`wayland` 实际上完全没有使用GPU:

.. literalinclude:: linuxserver_docker-calibre_gpu/calibre-backend.log
   :caption: 日志显示CPU软解压(未使用GPU)且出现Segmentation fault

可以看到上述日志中有以下异常: **纯 CPU 软解压与极高编码负荷** : 日志第 4 行显示 ``Decision: No GPU Encoder available -> Using CPU Software Encoding.`` ，且渲染分辨率高达 ``2560x1256 @ 60 FPS``

在我的服务器上，CPU是 :ref:`xeon_e-2274g` 内置了 :ref:`intel_uhd_graphics_630` ，另外系统安装了 :ref:`tesla_p10` ，所以检查 ``/dev/dri`` 可以看到有2个设备:

.. literalinclude:: linuxserver_docker-calibre_gpu/dri
   :caption: ``/dev/dri`` 目录下有2个设备

并且可以看出 ``card0`` 是 Intel GPU， ``card1`` 是 NVIDIA GPU

Intel GPU
==============

.. warning::

   我在gemini的指导下配置Intel GPU，但是没有成功，日志显示 ``Failed to create processing pipeline config: 12 (the requested VAProfile is not supported).``

   **NVIDIA 的 NVENC/NVDEC 硬件驱动在处理非标准分辨率、高分屏以及色彩空间转换（I420/NV12）时的弹性与兼容性，要远远比 Intel 严苛的 iHD 驱动宽容得多。**

由于 :ref:`nvidia_gpu` 性能更强功能更完备，所以我后续用于 :ref:`machine_learning` ，而这里图形系统加速就采用轻量级的  :ref:`intel_gpu` ，这样不仅物尽其用，而且也节能。

.. literalinclude:: linuxserver_docker-calibre-web/docker-compose_https.yml
   :lines: 21-37
   :emphasize-lines: 13,14

但是，仅仅将dri设备映射进容器，检查 ``docker logs calibre-backend`` 发现错误日志:

.. literalinclude:: linuxserver_docker-calibre-web/calibre-backend_gpu_err.log
   :caption: 显示初始化VAAPI失败，Intel GPU没有成功配置，依然使用CPU软渲染
   :emphasize-lines: 8,10

这里日志显示 ``Driver: ../../../bus/pci/drivers/i915`` 说明设备已经透传成功，容器确实正确拿到了Intel核显 :ref:`intel_uhd_graphics_630` 的硬件句柄。

但是 ``Failed to create processing pipeline config: 12 (the requested VAProfile is not supported)`` 表明容器内置的 ``FFmpeg/KasmVNC`` 试图在硬件层调用某种特定的色彩空间缩放或H.264编码配置(例如特定的 Low-Power 模式或特定的色彩位深)时， **Intel 的媒体驱动（Intel Media Driver）拒绝了这一请求，认为当前核显硬件的 VAProfile 无法支持此流水线** 。

这通常是因为 Linuxserver 容器默认使用的开源 VA-API 驱动版本、容器内部色彩空间格式与硬件加速管道冲突。在 ``docker-compose.yml`` 中 ``environment`` 部分添加以下3个环境变量来指定设备。另外，需要校准色彩空间模式（消除 scale_vaapi 管道阻塞），因为日志中显示当前容器激活的色彩空寂按是 ``Colorspace: I420 (Limited Range)`` : Intel 的硬件缩放过滤器（ ``scale_vaapi`` ）在处理 ``I420``  这种非硬件原生格式的帧时，极易报出 ``VAProfile is not supported`` 的配置管道错误 。Intel 核显更喜欢原生的 ``NV12`` 格式。所以需要在 ``environment`` 中再追加一个 ``KasmVNC/Selkies`` 底层视频流控制参数，强行让其在硬解时采用兼容性最好的全彩色范围:

.. literalinclude:: linuxserver_docker-calibre_gpu/docker-compose_https.yml
   :lines: 21-37
   :emphasize-lines: 13,14

.. note::

   Intel Xeon E-2274G 内置的 UHD P630 核显，其硬件视频编码器（MFE/MFX）在底层的硬件 Profile（VAProfile）中，不支持非标准分辨率（高为 ``1256`` 这种不能被 ``16`` 或 ``32`` 整除的非对齐分辨率）直接在 ``I420`` 格式下做硬件 ``scale_vaapi`` 图形缩放滤波。 驱动层直接抛出 ``12 (Unsupported)``  ，导致 FFmpeg 滤波器管道崩溃，瞬间回滚（Fallback）到了 CPU 软解 。

   所以，要避免 ``Failed to create processing pipeline config: 12 (the requested VAProfile is not supported)`` 需要利用 Selkies 容器自带的强权分辨率对齐机制（force_aligned_resolution），强行把高分屏下的分辨率约束为能被 16 整除的标准硬件格式。

   这就需要添加以下两个环境变量:

   .. literalinclude:: linuxserver_docker-calibre-web/force_aligned
      :caption: 强制对齐16像素

.. warning::

   太沮丧了，居然还是同样失败!!!

NVIDIA GPU
==============

由于实在搞不定Intel PGU，又不想死磕，所以改为采用 :ref:`tesla_p10` :  **NVIDIA 的 NVENC/NVDEC 硬件驱动在处理非标准分辨率、高分屏以及色彩空间转换（I420/NV12）时的弹性与兼容性，要远远比 Intel 严苛的 iHD 驱动宽容得多。**

经过一番折腾，在gemini指导下完成了配置:

.. literalinclude:: linuxserver_docker-calibre-web/docker-compose_https.yml
   :caption: 配置NVIDIA P10作为渲染硬件
   :lines: 21-64
   :emphasize-lines: 28,29,31,33-37,39,40

然后观察日志 ``docker logs calibre-backend`` 可以看到如下日志:

.. literalinclude:: linuxserver_docker-calibre_gpu/calibre-backend_nvidia.log
   :caption: 配置NVDIA的GPU成功初始化
   :emphasize-lines: 36-38

最后可以看到 ``NVENC Encoder initialized successfully`` 

此时在Host主机上执行 ``nvidia-smi`` 可以看到有一个使用GPU的进程:

.. literalinclude:: linuxserver_docker-calibre_gpu/nvidia-smi
   :caption: 使用 ``nvidia-smi`` 可以观察到一个计算类型 ``c`` 进程在使用GPU
   :emphasize-lines: 10
