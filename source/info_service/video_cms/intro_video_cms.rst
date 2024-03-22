.. _intro_video_cms:

==================
Video CMS简介
==================

缘起
=======

我最初是通过 :ref:`pixel_4` 手机来下载和播放视频:

- `低端影视 <https://ddys.art/>`_ 视频网站提供了 `夸克网盘 <https://pan.quark.cn>`_ 下载视频，提供了很多压制完美的mp4视频
- 夸克网盘客户端没有Linux版本，我最初动了 :ref:`wine` 模拟的心思，但是转念一想为了保持物理主机轻量化，需要将wine部署岛容器内部运行，比较折腾，需要等后续实践
- 夸克网盘的手机客户端比较方便，结合 :ref:`termux` 运行 :ref:`ssh` 服务，可以先用手机夸克客户端下载，再通过scp方式复制到电脑上观看(手机上直接观看也行)

但是，我突然想到，我有非常好的 :ref:`ipad_pro1` ，看视频非常舒畅，是不是可以在iPad上播放视频呢?

- 简单腾挪复制视频到iPad上当然可以，但是太麻烦了，也没有技术乐趣
- 既然 :ref:`pixel_4` 性能足够强大，何不将Android手机转换成移动的视频播放中心呢?

.. note::

   :ref:`kodi` 是一个在Linux/Android等平台运行的客户端程序，能够将视频源在方便播放的控制交互界面中播放，可以理解成手机中的视频播放软件。但是要提供WEB访问的良好组织的视频网站，需要一个精心设计的Video CMS。

   此外，需要学习和理解 :ref:`streaming_media` 所使用的不同 :ref:`streaming_protocol` ，以便能够更好实现播放

参考
=========

- `The best 15 open source open-source Video CMS YouTube alternatives <https://medevel.com/15-os-video-cms/>`_
- `7 Best Free / Open source Video CMS For Sharing Videos <https://www.how2shout.com/tools/best-open-source-video-cms-sharing-videos.html#google_vignette>`_
- `21 Open-source and Free Self-hosted Video CMS Publishing and Streaming Solutions <https://medevel.com/21-video-cms-and-streaming-solutions/>`_
