.. _imagemagick:

============
ImageMagick
============

和 :ref:`ffmpeg` 类似，ImageMagick是很多图形处理程序的核心，提供了大量的图形转换和处理功能。我后续将不断完善实践...

SVG转换
=========

很多web网站的图形采用了矢量图SVG，但是在 :ref:`sphinx_doc` 难以直接使用，所以通过 ImageMagick 的 ``convert`` 工具进行转换::

   #convert -background none -size 1024x1024 infile.svg outfile.png
   convert infile.svg outfile.png

参考
======

- `How to convert a SVG to a PNG with ImageMagick? <https://stackoverflow.com/questions/9853325/how-to-convert-a-svg-to-a-png-with-imagemagick>`_
