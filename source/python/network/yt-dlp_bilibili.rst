.. _yt-dlp_bilibili:

=========================
yt-dlp下载B站视频
=========================

:ref:`yt-dlp` 支持从Bilibili下载视频，而且由于B站的高清视频是将视频轨（.m4s）和音频轨（.m4s）分开传输的，使用 yt-dlp 还能够独立下载完这两个独立轨后，需要调用系统安装的 ffmpeg 将它们拼成一个带声音的 .mp4 文件。

由于视频轨和音频轨合成需要使用 :ref:`ffmpeg` ，所以在 macOS 上使用 :ref:`homebrew` 同时安装这两个软件:

.. literalinclude:: yt-dlp_bilibili/install
   :caption: 安装yt-dlp和ffmpeg

- 下载视频:

.. literalinclude:: yt-dlp_bilibili/dt-dlp
   :caption: 下载视频

不过，很可能会看到如下报错:

.. literalinclude:: yt-dlp_bilibili/dt-dlp_error
   :caption: 下载报错

这是因为触发了风控反爬机制，针对你的 IP 或请求返回了 HTTP 412: Precondition Failed。B站对未登录或未带有 Cookie 的 API 请求（尤其是 WBI 签名校验接口 x/player/wbi/playurl）进行了频繁度限制或鉴权拦截。

解决方法是让 ``yt-dlp`` 导入chrome的cookie:

.. literalinclude:: yt-dlp_bilibili/dt-dlp_cookie
   :caption: 使用cookie来下载B站视频

此时会提示输入登录本地用户登录密码以便从chorme中导出cookies，完成cookies导入后就会自动下载视频和对应音频文件，并自动合并成一个.mp4文件。

.. note::

   ``lux`` 开源软件也能做同样的B站下载，并且也支持通过ffmpeg来合并视频和音频轨
