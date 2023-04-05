.. _yt-dlp:

=================
yt-dlp
=================

`yt-dlp开源项目 <https://github.com/yt-dlp/yt-dlp>`_ 是 :ref:`youtube-dl` 的fork项目，提供了新功能和patch(合并了很多修复)，可以解决一些下载问题。

安装
=======

- ``pip`` 安装::

   python3 -m pip install -U yt-dlp

- :ref:`homebrew` 安装::

   # 安装
   brew install yt-dlp
   # 更新
   brew upgrade yt-dlp

.. note::

   配置方法和 :ref:`youtube-dl` 基本相同，例如配置文件是 ``~/.config/yt-dlp/config``

举例
=====

我非常喜欢的 `《杀死那个石家庄人》--万能青年旅店 影视混剪MV <https://www.youtube.com/watch?v=npHbCnf-Lpk&list=PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo&index=3>`_

- 首先获取视频列表::

   yt-dlp -F "https://www.youtube.com/watch?v=npHbCnf-Lpk&list=PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo&index=3"

显示输出:

.. literalinclude:: yt-dlp/yt-dlp_list_format
   :caption: ``yt-dlp -F`` 列出下载视频的输出案例 **《杀死那个石家庄人》--万能青年旅店 影视混剪MV**
   :emphasize-lines: 29

我来下载最小的一个视频mp4，编号 ``18`` ::

   yt-dlp -f 18 "https://www.youtube.com/watch?v=npHbCnf-Lpk&list=PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo&index=3"

.. note::

   请注意，上述列表中，很多视频文件是没有声音的( ``video only`` )，有些则只有声音( ``audio only`` )。如果你需要一个完整的有声音的视频，务必 **不要** 选择 ``video only`` 。

显示输出::

   [youtube:tab] Extracting URL: https://www.youtube.com/watch?v=npHbCnf-Lpk&list=PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo&index=3
   [youtube:tab] Downloading playlist PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo - add --no-playlist to download just the video npHbCnf-Lpk
   [youtube:tab] PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo: Downloading webpage
   WARNING: [youtube:tab] Unable to recognize playlist. Downloading just video npHbCnf-Lpk
   [youtube] Extracting URL: https://www.youtube.com/watch?v=npHbCnf-Lpk
   [youtube] npHbCnf-Lpk: Downloading webpage
   [youtube] npHbCnf-Lpk: Downloading android player API JSON
   [info] npHbCnf-Lpk: Downloading 1 format(s): 18
   [dashsegments] Total fragments: 1
   [download] Destination: /Users/huataihuang/Movies/《杀死那个石家庄人》--万能青年旅店   影视混剪MV.mp4
   [download] 100% of    22MiB in 00:00:04 at 399.36KiB/s

非常赞!!!

结合 :ref:`sphinx_embed_video` 就可以在我的个人网站上嵌入一段演示视频: 墙裂推荐观看YouTube原高清视频 => `《杀死那个石家庄人》--万能青年旅店 影视混剪MV <https://www.youtube.com/watch?v=npHbCnf-Lpk&list=PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo&index=3>`_

.. video:: ../../_static/devops/docs/sphinx_doc/ssngsjzr.mp4

参考
======

- `yt-dlp Installation <https://github.com/yt-dlp/yt-dlp/wiki/Installation>`_


