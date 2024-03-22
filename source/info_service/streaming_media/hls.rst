.. _hls:

=========================
HTTP Live Streaming(HLS)
=========================

206 Partial Content
========================

当使用简单的 :ref:`nginx_autoindex` 为客户端浏览器提供视频文件索引，浏览器中点击任何一个视频文件，都能够非常简单地实现播放。此时，在服务器端的nginx日志可以看到

.. literalinclude:: hls/nginx_206.log
   :caption: nginx日志中记录206返回码为客户端提供分片文件流化下载

参考
===========

- `Video Streaming Protocols: 6 Preferred Formats for Professional Broadcasting <https://www.dacast.com/blog/video-streaming-protocol/>`_
- `Streaming Protocols: Everything You Need to Know <https://www.wowza.com/blog/streaming-protocols>`_
- `Video streaming protocols explained: RTMP, WebRTC, FTL, SRT <https://restream.io/blog/streaming-protocols/>`_
- `Mozilla web docs: 206 Partial Content <https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/206>`_
