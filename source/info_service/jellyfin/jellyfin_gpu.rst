.. _jellyfin_gpu:

===========================
Jellyfin GPU加速
===========================

Jellyfin支持采用GPU进行视频转换，这里我采用容器来运行Jellyfin，就是先部署 :ref:`nvidia_container_toolkit` 以实现容器内NVIDIA硬件转换视频。

- :ref:`running_jellyfin_in_docker`

配置Jellyfin的GPU
====================

- 登录控制台 -> 播放 (Playback) -> 顶部的 硬件加速 (Hardware acceleration) 下拉菜单

  - 在 “硬件加速 (Hardware acceleration)” 下拉菜单中，默认是“无”，将其修改为： ``Nvidia NVENC``

    - 修改后，页面下方会弹出一大堆勾选框，此时需要按照自己的硬件，例如我是 :ref:`tesla_p10` 来选择Pascal 架构的硬件编解码编排 => Tesla P10 的 NVDEC 解码器支持绝大多数现代主流格式，勾选以下选项：

      - [x] H264
      - [x] HEVC (H.265)
      - [x] MPEG2
      - [x] VC1
      - [x] VP8

    - Tesla P10 **绝对不可以选择**

      - [ ] HEVC 10bit（P10 属于 Pascal 架构，该架构的 NVDEC 不支持 HEVC 10bit 的硬件解码，强开会导致播放 4K HDR 蓝光盘时直接报错黑屏）
      - [ ] VP9 / AV1（P10 硬件上不支持这两种格式的解码）

    - 确保勾选了

      - [x] 勾选 “启用增强型NVDEC解码器” (Enable enhanced NVDEC decoder)
      - [x] 勾选 “启用硬件编码” (Enable hardware encoding)

  - 高级调优设置（榨干 24GB 显存）

    - 启用色调映射（Hardware Tone Mapping）: 如果高画质电影是 HDR 格式，而你的手机或浏览器只支持 SDR，P10 会通过 CUDA 核心实时进行色彩转换，让画面不发灰。
    - 并发转码限制（Max Simultaneous Video Transcoding Streams）：

      - 默认是 0（不限制）。得益于P10 24GB 显存，普通的消费级显卡（如 GTX 1050）在驱动层面被 NVIDIA 锁死只能同时转码 3-5 路，但 Tesla 系列计算卡在驱动层面是完全解锁并发限制的！
      - 只要显存够，这块 P10 可以同时为局域网内的几十台设备进行 1080p 视频转码。因此保持 0 即可。

在完成了上述硬件加速配置之后，当视频播放时选择了特定Qulity(和原片不同格式)，此时服务器端就会看到 ``ffpmeg`` 开始工作，对于启用了GPU硬件加速的环境， **ffmpeg的CPU使用率极低，并且nvidia-smi显示有ffmpeg进程在处理**

.. literalinclude:: running_jellyfin_in_docker/nvidia-smi_ffmpeg
   :caption: 当ffmpeg使用GPU加速转换时可以看到 ``nvidia-smi`` 中显示GPU工作
   :emphasize-lines: 19

排查
-------

我发现实际上视频转换时，服务器端 ``ffmpeg`` 疯狂消耗了CPU，但是 ``nvidia-smi`` 显示GPU却 "纹丝未动"

- 有一种可能是Docker引擎没有配置 :ref:`nvidia_container_toolkit` ，所以需要通过容器内 ``nvidia-smi`` 验证：

.. literalinclude:: running_jellyfin_in_docker/nvidia-smi
   :caption: 执行容器内 ``nvidia-smi``
   :emphasize-lines: 10

输出显示容器内其实是可以正常使用GPU的，有输出:

.. literalinclude:: running_jellyfin_in_docker/nvidia-smi_output
   :caption: 执行容器内 ``nvidia-smi`` 显示GPU的 :ref:`nvidia_container_toolkit` 配置正确

- 登录到 Jellyfin 平台，检查转码日志(Jellyfin 每一次转码失败，都会生成一个独立的 FFmpeg.Transcode.xxx.log 运行日志)

  - 登录 Jellyfin 网页后台 -> 控制台 (Dashboard) -> 日志 (Logs)

.. literalinclude:: running_jellyfin_in_docker/ffmpeg_no_nvenc.log
   :caption: ffpmeg日志显示转换没有使用 NVIDIA 硬件加速编码

这里可以看到 使用了纯 CPU 编码器 ``libx264`` : 如果成功启用了 NVIDIA 硬件加速编码，这里应该显示的是 ``-codec:v:0 h264_nvenc`` （由 NVIDIA GPU 的专用硬件编码芯片接管），但是很不幸这里看到的是 ``-codec:v:0 libx264`` (开源 CPU 软件编码器)。

为什么 Jellyfin 不传 GPU 参数？

**乌龙了：原来我上一次配置GPU加速设置忘记点击save按钮**
