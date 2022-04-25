.. _mpd:

========================
MPD(Music Player Daemon)
========================

MPD(Music Player Daemon)是一个客户服务器架构的音频播放器，用于播放音频文件，管理播放列表以及维护一个音乐数据库。这些功能都使用非常少的资源，而且可以使用不同的独立客户端。

安装
=======

- 在 :ref:`ubuntu_linux` 上安装::

   sudo apt install mpd

配置
======

MPD可以运行在 ``按用户配置`` 和 ``系统范围配置`` (配置针对所有用户)两种模式，也可以在一个主机上运行多个MPD实例。最简单的设置方法是本地 ``按用户配置`` ，比较适合桌面系统。而 ``系统范围配置`` 则较为适合音频服务器，可以多个用户共享一个MPD实例。

要让MPD能够播放音频，需要设置 :ref:`alsa` 或者 :ref:`pulseaudio` 或 ``PipeWire`` 

MPD通过 ``mpd.conf`` 配置，该配置可以按用户模式和系统模式:

- ``~/.config/mpd/mpd.conf`` 是每个用户配置
- ``/etc/mpd.conf`` 系统范围配置

常用配置:

- ``pid_file`` : 存放MPD进程ID
- ``db_file`` : 音乐数据库
- ``state_file`` : MPD当前状态
- ``playlist_directory`` : 保存播放列表的目录
- ``music_directory`` : MPD扫描音乐的目录
- ``sticker_file`` : 便签数据库，存储音乐相关信息

每个用户的独立配置
-------------------

- 复制配置文件::

   mkdir ~/.config/mpd
   cp /usr/share/doc/mpd/mpdconf.example.gz ~/.config/mpd/
   cd ~/.config/mpd
   gzip -d mpdconf.example.gz
   mv mpdconf.example mpd.conf

- 修订 ``~/.config/mpd/mpd.conf`` :

.. literalinclude:: mpd/mpd.conf
   :language: bash
   :caption: ~/.config/mpd/mpd.conf 配置案例

根据配置需要创建一个playlists子目录::

   mkdir ~/.config/mpd/playlists

- 启动 ``mpd`` ::

   mpd ~/.config/mpd/mpd.conf

提示信息::

   Apr 25 15:09 : server_socket: bind to '0.0.0.0:6600' failed (continuing anyway, because binding to '[::]:6600' succeeded): Failed to bind socket: Address already in use
   Apr 25 15:09 : decoder: Decoder plugin 'wildmidi' is unavailable: configuration file does not exist: /etc/timidity/timidity.cfg
   Apr 25 15:09 : exception: Failed to open '/home/huatai/.config/mpd/database': No such file or directory
   Apr 25 15:09 : output: No 'audio_output' defined in config file
   Apr 25 15:09 : output: Successfully detected a sndio audio device

- 检查服务::

   ps aux | grep mpd

可看到::

   huatai    139542  1.3  1.1 444124 44992 ?        Ssl  15:09   0:01 mpd /home/huatai/.config/mpd/mpd.conf

- 检查端口::

   lsof | grep 6600

::

   ...
   mpd       139542                            huatai   11u     IPv6             615750       0t0        TCP *:6600 (LISTEN)
   mpd       139542 139544 io                  huatai   11u     IPv6             615750       0t0        TCP *:6600 (LISTEN)
   mpd       139542 139545 rtio                huatai   11u     IPv6             615750       0t0        TCP *:6600 (LISTEN)

- 如果没有设置 ``auto_update=yes`` 则可以使用 ``mpc`` 客户端更新数据库::

   mpc update

音频配置
-----------

如果使用了 :ref:`alsa` 在默认设备使用 ``autodection`` 就可以工作，无需任何配置。

不过我在 :ref:`pi_400` 上使用HDMI输出，需要明确配置ALSA音频输出定义才能工作： 这个精确的设备定义可以通过 ``aply --list-pcm`` 获得

.. literalinclude:: mpd/aplay_list-pcm
   :language: bash
   :caption: aplay --list-pcm 输出信息

以下是配置案例:

.. literalinclude:: mpd/mpd_audio_output.conf
   :language: bash
   :caption: ~/.config/mpd/mpd.conf audio_output 配置案例

将上述配置添加到 ``~/.config/mpd/mpd.conf`` 中，然后重启 ``mpd`` 服务，就能够正确定义音频输出

以 :ref:`systemd` 自动启动
------------------------------

- 执行以下命令启动 user unit mpd.service::

   sudo systemctl enable mpd.service --user

则配置文件将读取 ``~/.config/mpd/mpd.conf``

以 tty login自动启动
--------------------------

如果要在tty登陆时候子偶的那个启动mpd，则配置 ``~/.profile`` ::

   # MPD daemon start (if no other user instance exists)
   [ ! -s ~/.config/mpd/pid  ] && mpd

客户端
=======

字符终端 ``ncmpc``
--------------------

如果你像我一样追求轻量级应用，不需要任何花哨的界面，你可以像我一样使用字符终端mpd客户端，例如 ``ncmpc`` 

- 在终端执行 ``ncmpc`` 命令，会打开基于 ``ncurse`` 的控制台，并且立即连接到默认的本地 ``mpd`` 服务上，此时就可以看到服务器上所有的音乐
- 在导航栏上的数字 ``1`` ``2`` ... 分别代表 ``F1`` ``F2`` ... 以此类推，最后2个字母分别是小写的 ``i`` 和大写的 ``K`` ，真的是对应操作键 ``i`` 和 ``K`` ，总之，按照对应操作键进入菜单就会明白怎么操作。
- 快捷键的绑定在 ``K`` 上，通过上下键找到操作命令，按下回车就可以看到命令对应绑定的快捷键，例如:

  - ``t`` 表示选择所有
  - ``a`` 表示将选择的项添加到队列

- 将音乐加入到队列中之后，就可以在队列中按下回车开始依次聆听

QT5图形 ``cantata``
-----------------------

``cantata`` 实际上不需要上述手工配置 ``mpd.conf`` ，因为只要系统中安装了 ``mpd`` ， ``cantata`` 启动时候就会自动引导你做一些简单配置(也就是选择音乐所在目录)，然后程序运行起来以后，你就会看到后台运行了一个 ``mpd`` 服务并且使用了 ``cantata`` 自动生成的 ``mpd.conf`` 配置文件。

简单来说， ``cantata`` 提供了自动配置 ``mpd`` 的功能来帮助你简化使用。不过，需要注意，在 :ref:`pi_400` 上必须使用 HDMI 作为音频设备，这个配置需要手工添加，见上文。

参考
======

- `MPD User's Manual <https://mpd.readthedocs.io/en/stable/user.html>`_
- `arch linux: Music Player Daemon <https://wiki.archlinux.org/title/Music_Player_Daemon>`_
