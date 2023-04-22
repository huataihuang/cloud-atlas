.. _ffmpeg:

=============
ffmpeg
=============

ffmpeg是广泛使用的视频转换工具，也提供了对图片格式的转换，这是一个非常强大的工具，也是很多视频和视频剪辑软件的核心。

webp转换
===========

在这里，我使用 ``ffmpeg`` 做图形格式转换，将 ``webp`` 转换成 ``png`` ，实际上还是杀鸡用牛刀::

   ffmpeg -i file.webp file.png

转换后的 PNG 文件要比原始的 WEBP 文件大很多，所以可能还需要做优化处理。

其他用于转换 WEBP的工具是 ``libwebp`` 

.. note::

   我希望后续在 :ref:`web` 探索中研究 ``ffmpeg`` ，待续

mp4视频压缩
==============

在使用 :ref:`yt-dlp` 制作 :ref:`sphinx_embed_video` ，我发现YouTube视频可能对于我的个人演示网站来说还是太大了，所以我需要进一步缩小视频文件大小:

.. literalinclude:: ffmpeg/ffmpeg_reduce_mp4_size
   :caption: ffmpeg缩减mp4视频文件大小(这个方法可能和原始视频编码有关，我测试YouTube视频压缩后 :ref:`macos` 无法兼容播放)

- 缩小规格方式:

  .. literalinclude:: ffmpeg/ffmpeg_change_video_screen-size
     :caption: ffmpeg缩小视频屏幕尺寸来缩小视频(编码不变，通用性好

参考
====

- `How to Convert WebP to PNG in Linux <https://winaero.com/convert-webp-png-linux/>`_
- `How can I reduce a video's size with ffmpeg? <https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg>`_ 这个问答提供了很多转换案例，可以参考尝试
