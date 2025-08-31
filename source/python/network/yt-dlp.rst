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

提取cookies
=============

要下载油管文件，需要为 ``yt-dlp`` 提供cookies。有以下一些方法

使用 ``yt-dlp`` 提取chrome的cookies
-------------------------------------

``yt-dlp`` 无需使用第三方就可以提取chrome浏览器的cookie:

.. literalinclude:: yt-dlp/cookies-from-browser
   :caption: 提取chrome的cookies

上述命令将浏览器的cookies保存为cookies.txt文件。这个cookies.txt文件后续就可以 ``--cookies`` 参数用于下载油管文件。不过，需要注意这个cookies.txt报案了所有网站的cookies，所以一定要保障安全。

使用 ``chrome`` 保存cookies
------------------------------

``chrome`` 的私有浏览窗口可以导出cookies:

- 在浏览器中使用一个新的 private browsing/incognito 窗口，并登陆到YouTube
- 在同一个窗口和相同的tab中，访问 ``https://www.youtube.com/robots.txt``
- 使用第三方export cookies来输出当前incognito窗口的cookies:

  - chrome推荐使用 `Get cookies.txt LOCALLY chrome插件 <https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc>`_ (注意: **需要在插件管理页面勾选 "Allow in Incognito" 才能在隐私页面中使用** )
  - firefox推荐使用 `cookies.txt firefox插件 <https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/>`_

.. figure:: ../../_static/python/network/get_cookies.txt_locally.png

   在chrome中激活 "Allow in Incognito" 选项以后可以使用 ``Get cookies.txt LOCALLY chrome插件`` 保存当前页面的cookies

.. note::

   chrome处于incongnito状态时，代理配置使用的是系统设置proxy(默认情况下常规的proxy插件不生效，除非配置 "Allow in Incognito")。我是通过设置系统代理方式来实现incognito 窗口访问YouTube

使用
=====

我非常喜欢的 `《杀死那个石家庄人》--万能青年旅店 影视混剪MV <https://www.youtube.com/watch?v=npHbCnf-Lpk>`_

- 首先获取视频列表::

   yt-dlp -F "https://www.youtube.com/watch?v=npHbCnf-Lpk" --cookies www.youtube.com_cookies.txt

这里参数 ``--cookies www.youtube.com_cookies.txt`` 是指定刚才从chrome的Incognito页面export出来的cookie文件

显示输出:

.. literalinclude:: yt-dlp/yt-dlp_list_format
   :caption: ``yt-dlp -F`` 列出下载视频的输出案例 **《杀死那个石家庄人》--万能青年旅店 影视混剪MV**
   :emphasize-lines: 29

我来下载最小的一个视频mp4，编号 ``18`` ::

   yt-dlp -f 18 "https://www.youtube.com/watch?v=npHbCnf-Lpk" --cookies www.youtube.com_cookies.txt

.. note::

   请注意，上述列表中，很多视频文件是没有声音的( ``video only`` )，有些则只有声音( ``audio only`` )。如果你需要一个完整的有声音的视频，务必 **不要** 选择 ``video only`` 。

显示输出::

   [youtube:tab] Extracting URL: https://www.youtube.com/watch?v=npHbCnf-Lpk
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

结合 :ref:`sphinx_embed_video` 就可以在我的个人网站上嵌入一段演示视频: 墙裂推荐观看YouTube原高清视频 => `《杀死那个石家庄人》--万能青年旅店 影视混剪MV <https://www.youtube.com/watch?v=npHbCnf-Lpk>`_

.. video:: ../../_static/devops/docs/sphinx_doc/ssngsjzr.mp4

快速下载喜爱的音频文件
========================

经常听的的歌曲，建一个 ``playlist`` 列表，可以使用 ``yt-dlp`` 获取这个列表中的所有视频的IDs:

.. literalinclude:: yt-dlp/get-id
   :caption: 获取 ``playlist`` 列表所有视频的IDs


然后一次性从Youtube下载音频:

.. literalinclude:: yt-dlp/yt-dlp_songs.sh
   :language: bash
   :caption: 下载自己喜欢的歌曲

参考
======

- `yt-dlp Installation <https://github.com/yt-dlp/yt-dlp/wiki/Installation>`_


