.. _youtube-dl:

======================
youtube-dl
======================

.. note::

   目前(2023年4月)，使用 ``youtube-dl`` 下载会遇到 metadata 错误问题，改为采用 :ref:`yt-dlp` 

`ytdl-org/youtube-dl <https://github.com/ytdl-org/youtube-dl>`_ 是著名的开源YouTbue视频下载工具，使用 Python 开发，安装简易，使用方便。

安装
======

- 在所有UNIX平台(Linux, macOS,等)可以使用如下命令:

.. literalinclude:: youtube-dl/unix_install_youtube-dl
   :language: bash
   :caption: 在UNIX平台上安装 ``youtube-dl``

- 另一种方便的安装方法是使用 ``pip`` :

.. literalinclude:: youtube-dl/pip_install_youtube-dl
   :language: bash
   :caption: 使用pip安装 ``youtube-dl``

- 在 :ref:`macos` 平台使用 :ref:`homebrew` 安装最为方便:

.. literalinclude:: youtube-dl/brew_install_youtube-dl
   :language: bash
   :caption: 使用 :ref:`homebrew` 安装 ``youtube-dl``

使用
========

``youtube-dl`` 是一个命令行下载YouTube的工具，只需要系统有Python就能运行，所以是跨平台工具，简单使用方法::

   youtube-dl [OPTIONS] URL [URL...]

一些有用的参数

- ``--proxy 127.0.0.1:3128`` 使用代理服务
- ``-o ~/Movies/%(title)s.%(ext)s`` 将下载视频保存到home目录

配置文件保存在 ``/etc/youtube-dl.conf`` (全局) 或 ``~/.config/youtube-dl/config`` (个人)

.. note::

   建议使用 ``~/.config/youtube-dl/config`` 保存配置，特别是代理配置，这样下载会非常方便

使用 ``.netrc`` 文件认证
-------------------------

对于需要认证的访问，可以存储证书::

   touch $HOME/.netrc
   chmod a-rwx,u+rw $HOME/.netrc

   # 格式: machine <extractor> login <login> password <password>
   machine youtube login myaccount@gmail.com password my_youtube_password
   machine twitch login my_twitch_account_name password my_twitch_password

- 支持下载指定YouTube页面，会自动分析视频链接并下载对应视频
- 支持多个下载页面，只需要依次将下载URL用空格分隔一次性输入即可
- 支持视频列表完整下载，也就是你只要将需要下载的视频整理到一个列表中就可以一次性下载完成

下载不同画质和文件类型
------------------------

``youtube-dl`` 的参数 ``-f`` 可以指定画质和文件类型，对应还有一个 ``-F`` 参数可以显示全部可选的画质和类型

下载字幕
------------

参数 ``--with-sub`` 可以在下载时同时下载字幕，默认格式是 ``vtt`` ，如果需要使用其他格式字幕，例如 ``srt`` 格式，则使用 ``--sub-format srt``

使用 ``--list-subs`` 可以查看所有多语言字幕，则使用 ``--sub-lang`` 选择字幕语言

问题排查
=========

实际使用 ``youtube-dl`` 会发现有报错::

   ERROR: Unable to extract uploader id; please report this issue on https://yt-dl.org/bug . 
   Make sure you are using the latest version; type  youtube-dl -U  to update. 
   Be sure to call youtube-dl with the --verbose flag and include its complete output.

我加上了 ``--verbose`` 参数看到报错位于::

   'uploader_id': self._search_regex(r'/(?:channel|user)/([^/?&#]+)', owner_profile_url, 'uploader id') if owner_profile_url else None,
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   File "/usr/local/bin/youtube-dl/youtube_dl/extractor/common.py", line 1012, in _search_regex
    raise RegexNotFoundError('Unable to extract %s' % _name)   

这个问题在 `[YouTube] Unable to extract uploader id #31530 <https://github.com/ytdl-org/youtube-dl/issues/31530>`_ 提供了解决方法:

原因四YouTube更改了metadata服务，目前即使升级 ``youtube-dl`` ( ``youtube-dl -U`` ) 也解决不了(因为升级只是升级到2021年的release版本)，但是可以采用从 ``youtube-dl`` fork出来的项目 :ref:`yt-dlp` (提供了更多新功能和patch)

参考
======

- `ytdl-org/youtube-dl <https://github.com/ytdl-org/youtube-dl>`_
- `开源而强大的视频下载工具——youtube-dl <https://sspai.com/post/42409>`_
