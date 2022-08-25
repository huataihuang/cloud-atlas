.. _ffmpeg:

=============
ffmpeg
=============

ffmpeg是广泛使用的视频转换工具，也提供了对图片格式的转换，这是一个非常强大的工具，也是很多视频和视频剪辑软件的核心。

在这里，我使用 ``ffmpeg`` 做图形格式转换，将 ``webp`` 转换成 ``png`` ，实际上还是杀鸡用牛刀::

   ffmpeg -i file.webp file.png

转换后的 PNG 文件要比原始的 WEBP 文件大很多，所以可能还需要做优化处理。

其他用于转换 WEBP的工具是 ``libwebp`` 

.. note::

   我希望后续在 :ref:`web` 探索中研究 ``ffmpeg`` ，待续

参考
====

- `How to Convert WebP to PNG in Linux <https://winaero.com/convert-webp-png-linux/>`_
