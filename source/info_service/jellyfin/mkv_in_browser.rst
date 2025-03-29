.. _mkv_in_browser:

========================
在浏览器中播放MKV视频
========================

``.mkv`` 视频不是HTML5支持的各式，所以通常需要先转换成 ``.mp4`` 才能直接在浏览器中播放(例如直接通过网页索引文件)。不过
   ``chrome`` 内置了MKV视频播放能力，所以只要在页面中嵌入

.. literalinclude:: mkv_in_browser/mkv.html
   :language: html
   :caption: 在页面中嵌入MKV

但是，这个方法对于 safari 无效

我在 :ref:`install_jellyfin_pi` 后尝试发现，原来Jellyfin能够直接使用.mkv视频作为播放源，此时浏览器能够直接播放视频，非常方便。具体技术细节待研究。

参考
======

- `How to playback MKV video in web browser? <https://stackoverflow.com/questions/21192713/how-to-playback-mkv-video-in-web-browser>`_
