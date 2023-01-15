.. _live_streaming_arch:

========================
直播技术架构
========================

.. note::

   目前仅做资料整理，梳理直播涉及的技术堆栈，后续再做实践

流程
=======

- 采集

  - iOS
  - Android
  - PC端: 采用开源 OBS (Open Broadcaster Software) Studio - 内置编码，支持RTMP官博，多源、网络摄像头、绿屏、视频捕捉卡

- 直播互动:

基于 WebRTC 实时通讯技术 (本地用户（主播）和远程用户（连麦观众）之间的连接通过 RTCPeerConnection API 管理，这个 API 包装了底层流管理和信令控制相关的细节)

- 处理

  - iOS端有 `GPUImage库 <https://github.com/BradLarson/GPUImage>`_ 提供丰富端预处理效果(美颜、视频处理如模糊效果、水印等)
  - Android端有GPUImage的移植( `android-gpuimage <https://github.com/CyberAgent/android-gpuimage>`_ )，此外Google官方开源库覆盖了 `Android上多媒体和图形图像处理库 <https://github.com/google/grafika>`_

- 编码

- 推流和传输

我非常欣赏 `低端影视 <https://ddys.art/>`_ 视频网站，高清视频配合外挂字幕，可以看到视频采用了CDN加速技术

- 转码

服务器端提供转码功能将提供不同格式和协议，如RTMP, HLS 和 FLV 

一些思路
==========

`浅谈直播技术 <https://huangruichang.github.io/?techniques/live-tv/index>`_ 虽然是好些年前的文章，但是提到的 `网络直播需要哪些设备和技术？ <https://www.zhihu.com/question/22421708>`_ 有很多技术索引。并且参考 `ffmpeg+nginx+nginx-rtmp-module 搭建 rtmp hls http 流媒体服务器成功经验分享 <http://www.codeclip.com/3724.html>`_

`VideoLAN <https://www.videolan.org/>`_ (即VLC)提供了开源跨平台多媒体播放器和框架，能够显示流媒体播放

- 传输加速技术(待调研): :ref:`kcp`


参考
=======

- `《视频直播技术详解》系列之一：视频采集和处理 <https://www.techug.com/post/live-video-tech/>`_
- `适用于 Linux 的五大流媒体直播应用 <https://mp.weixin.qq.com/s/As2EVWdr-aEFeDo3KcDTOg>`_
- `网络直播需要哪些设备和技术？ <https://www.zhihu.com/question/22421708>`_ 有很多技术索引
- `直播技术栈 #10 <https://github.com/rainzhaojy/blogs/issues/10>`_
