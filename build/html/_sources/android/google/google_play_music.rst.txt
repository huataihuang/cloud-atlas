.. _google_play_music:

====================
Google Play Music
====================

Google Play Music for Chrome
===============================

最方便管理(上传和下载)音乐的方法是使用Google Chrome，因为Google提供了 `Google Play Music for Chrome <https://chrome.google.com/webstore/detail/google-play-music/fahmaaghhglfmonjliepjlchgpgfmobi>`_ 这个web extension提供了桌面播放器，也提供了对Google Play上传下载音乐的功能。

- 首次启动Google Play Music提示需要设置

.. figure:: ../../_static/android/google/google_play_music_started.png
   :scale: 50

但是，通过 `Google Play Music for Chrome <https://chrome.google.com/webstore/detail/google-play-music/fahmaaghhglfmonjliepjlchgpgfmobi>`_ 安装的Google Play Music程序首次启动设置提示的页面是完全空白的，显示只有部分区域是开通Google Play Music服务，所以没有找到使用方法。

Google Music Manager
=======================

.. note::

   我实践发现Google Music Manager现在已经无法登陆，即使已经按照错误提示确保了浏览器中Google Music已经登陆了相同的账号。估计Google是为了强制用户切换到自家的网上音乐商店，限制了个人自己上传下载音乐。所以，我放弃使用Google Music，改为采用VLC Player来播放音乐和视频。

`Google Play Music Manager <https://play.google.com/music/listen?u=0#/manager>`_ 是Google开发的提供管理音乐的工具，并且可以在Windows, Mac和一些Linux发行版工作。只要通过Music Manager登陆了Google账号，就能够完成一些基本管理任务：

- 从iTunes或Windows Media Player上传音乐，或者从特定目录上传音乐
- 可以从Google Play Music仓库下载免费或者已经购买的音乐，或者整个音乐库

这个Music Manager可以在后台运行(关闭窗口依然在后台上传下载)，所以虽然其上传下载速度不快，但不影响你使用Internet。

.. note::

   为何我们不能直接使用 adb 来上传下载Android中Google Play Music的音乐呢？这是因为Google的Play Music app只是一个皮肤，实际上后台使用的是Google Play Movies。虽然音乐存储在你的手机中，但是却是加密文件，所以其他音乐app不能看到这些音乐。

.. note::

   虽然Google Play Music和Apple Music类似，提供了在线音乐欣赏，但是由于Google服务在墙内使用不便，也很难订阅，所以推荐使用开源的 VLC 播放器来聆听音乐和观看视频。当然，如果你能订阅的话，使用Play Music也不错。

参考
========

- `How to upload and download music on Google Play Music <https://www.androidcentral.com/uploading-and-downloading-music-google-play-music>`_
- `How to upload and download music on Google Play Music <https://www.androidcentral.com/uploading-and-downloading-music-google-play-music>`_
