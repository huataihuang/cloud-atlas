.. _sphinx_image:

==================
Sphinx图片
==================

在Sphinx中，有两种图片嵌入方法 ``image`` 和 ``figure`` :

- ``image`` 是一种简单图片
- ``figure`` 则提供了更多选项: 图像数据（包括图像选项）、可选标题（单个段落）和可选图例（任意正文元素）。对于基于页面的输出媒体，如果有助于页面布局， ``figure`` 可能会浮动到不同位置

使用案例
===========

- ``image`` 代码案例:

.. literalinclude:: sphinx_image/image

- ``figure`` 代码案例:

.. literalinclude:: sphinx_image/figure

.. note::

   我之前使用过一段时间 ``image`` ，后来转为 ``figure`` ，简单使用并没有太大差异。

图像格式
===========

我在撰写文档的时候，经常会截图(并简单标注一下)，由于通常在 :ref:`macos` 桌面工作，所以我截图往往使用IM软件内置的截图工具并简单标注，然后将图片复制到macOS自带的 ``preview`` 程序，能够简单缩放然后保存成 ``png`` 或 ``jpg`` 文件。

不过，我也发现了不论是 ``png`` 还是 ``jpg`` ，文件都比较庞大，特别是现在高分辨率屏幕，简单的截图都会达到几百K甚至上兆。实际上，这对WEB页面非常不友好(虽然现在大家带宽都很大，但是我感觉还是消耗了太多资源)。

惭愧，最近才注意到 ``webp`` 格式图片，可以将相同的 ``png`` 缩小到 1/4 大小而没有什么画质影响。而且 Sphinx 也支持嵌入 ``webp`` 图片，这对编写电子书非常友好。

图像格式转换
==============

:ref:`macos` 内置的 ``preview`` 不支持 ``webp`` 格式图片，不过Linux提供了 ``libwebp`` 库工具来进行格式转换:

- ``dwebp`` : 将 ``webp`` 转换成其他图像格式(decode)
- ``cwebp`` : 将其他图像格式转换成 ``webp`` (encode)

举例::

   dwebp image.webp -o final.png

   dwebp image.webp -o final.jpeg

   cwebp image.png -o image.webp

建议将图像转换成 ``webp`` 格式，这个图像格式目前得到所有主流浏览器支持，可以大大节约图像下载占用的带宽。

.. note::

   可以使用 :ref:`parallel` 工具并发转换大量图片，充分利用多处理器的性能


参考
======

- `How do we embed images in sphinx docs? <https://stackoverflow.com/questions/25866102/how-do-we-embed-images-in-sphinx-docs>`_
- `How to Convert WebP Images to PNG and JPEG in Linux <https://www.linuxshelltips.com/convert-webp-to-png-jpeg-linux/>`_
