.. _mpd:

========================
MPD(Music Player Daemon)
========================

MPD(Music Player Daemon)是一个客户服务器架构的音频播放器，用于播放音频文件，管理播放列表以及维护一个音乐数据库。这些功能都使用非常少的资源，而且可以使用不同的独立客户端。

MPD（Music Player Daemon）支持播放无损音乐以及绝大多数主流/非主流音频格式。

MPD 自身是一个轻量的架构，其音频解码能力取决于编译时启用的后端插件库（通过 Linux 系统下的 FFmpeg、FLAC、libsndfile 等解码库支持）。在 Alpine Linux 下，默认包管理器安装的 MPD 已经内置了常用无损格式的支持。

MPD 支持的主要无损与高码率格式:

- FLAC (.flac)：完全原生支持，Linux 下最推荐的无损格式（支持 16bit/24bit 及高达 192kHz/DSD 采样率）。
- APE (.ape)：Monkey's Audio，通过 FFmpeg 解码插件完整支持。
- WAV / AIFF (.wav, .aiff)：未压缩无损音频，原生直接支持。
- ALAC (.m4a)：Apple Lossless，苹果无损音频，完全支持。
- WAVPACK (.wv)：高质量开源无损格式，完全支持。
- DSD / DSF / DFF (.dsf, .dff)：支持 DSD 源码输出（DoP）或软解转化为 PCM 输出（需在 mpd.conf 中配置）。

安装
=======

- 在 :ref:`ubuntu_linux` 上安装::

   sudo apt install mpd

- 在Alpine 的 mpd 包通常已经包含了常规解码器:

.. literalinclude:: mpd/alpine_install
   :caption: 安装

.. note::

   MPD 主程序本身非常小巧（通常仅几 MB），但在 Alpine Linux 的官方打包中，为了保证它能“开箱即用”地支持各种音频格式、网络流媒体以及输出设备，打包者在编译时开启了大多数扩展特性:

   - 音频解码：依赖 ffmpeg、libflac、libvorbis 等，而 ffmpeg 自身又依赖庞大的图像/视频处理库。
   - 网络与协议：依赖 curl、smbclient 等（用于读取网络共享或 Web Radio）。
   - 音效处理：依赖 libsamplerate、soxr（音频重采样库）。

   这导致安装软件包数量非常庞大，对于轻量级使用非常浪费。所以，建议发挥MPD原生"服务器/客户端（Client/Server）架构"优势，部署 :ref:`mpd_stream`

配置
======

MPD可以运行在 ``按用户配置`` 和 ``系统范围配置`` (配置针对所有用户)两种模式，也可以在一个主机上运行多个MPD实例。最简单的设置方法是本地 ``按用户配置`` ，比较适合桌面系统。而 ``系统范围配置`` 则较为适合音频服务器，可以多个用户共享一个MPD实例。

要让MPD能够播放音频，需要设置 ``ALSA`` 或者 :ref:`pulseaudio` 或 ``PipeWire`` 

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

.. literalinclude:: mpd/pi_os_mpd.conf
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

如果使用了 ``ALSA`` 在默认设备使用 ``autodection`` 就可以工作，无需任何配置。 **确实如此**

不过我在 :ref:`pi_400` 上使用HDMI输出，需要明确配置ALSA音频输出定义才能工作： 精确的设备定义可以通过 ``aplay --list-pcm`` 获得

.. literalinclude:: mpd/kali_aplay_list-pcm
   :language: bash
   :caption: Kali Linux 上 aplay --list-pcm 输出信息

以下是 :ref:`kali_linux` 在 :ref:`pi_400` 的配置案例:

.. literalinclude:: mpd/mpd_audio_output.conf
   :language: bash
   :caption: ~/.config/mpd/mpd.conf audio_output 配置案例

但是我在 ``Raspberry Pi OS`` 上执行 ``aplay --list-pcm`` 显示的信息就和 :ref:`kali_linux` 不同，如下:

.. literalinclude:: mpd/pi_os_aplay_list-pcm
   :language: bash
   :caption: Raspberry Pi OS 上 aplay --list-pcm 输出信息

但是，我在 ``Raspberry Pi OS`` 没有找到如 :ref:`kali_linux` 的配置设备方法，反而是完全遵循 `Debian Wiki: mpd <https://wiki.debian.org/mpd>`_ ，即不配置任何设备，只设置::

   audio_output {
           type            "alsa"
           name            "My ALSA Device"
   }   

却完全工作正常。所以我在 ``Raspberry Pi OS`` 使用的是如下配置:
   
.. literalinclude:: mpd/pi_os_mpd.conf
   :language: bash
   :caption: 我现在在Raspberry Pi OS 使用的 ~/.config/mpd/mpd.conf 配置

.. note::

   我在实践中发现，当使用 ``ALSA`` 直接作为音频输出设备，但是同时运行 :ref:`pulseaudio` 服务，则在 :ref:`pi_400` 的HDMI输出声音中总是有沙沙的噪音。杀掉 ``pulseaudio`` 服务之后则恢复正常。

   由于我在 ``mpd`` 中使用 ``ALSA`` ，并且也配置了VLC直接使用ALSA，所以配置关闭了 :ref:`pulseaudio` 服务

以 :ref:`systemd` 自动启动
------------------------------

- 执行以下命令启动 user unit mpd.service::

   sudo systemctl enable mpd.service --user

则配置文件将读取 ``~/.config/mpd/mpd.conf``

以 tty login自动启动
--------------------------

如果要在tty登陆时候自动启动mpd，则配置 ``~/.profile`` ::

   # MPD daemon start (if no other user instance exists)
   [ ! -s ~/.config/mpd/pid  ] && mpd ~/.config/mpd/mpd.conf

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

.. note::

   使用 ``ncmpc`` 这样的客户端来使用 ``mpd`` 播放音乐的优点是只要激活播放，就可以关闭客户端程序，后台的 ``mpd`` 服务会继续工作，也就是继续播放音乐。前端客户端其实只是起一个控制作用。也就是说，设置可以使用 :ref:`sway` 快捷键来管理 ``mpd`` 的常规播放，就好像在 Mac 电脑上，可以使用键盘按键来操作音乐播放一般，非常酷。

QT5图形 ``cantata``
-----------------------

``cantata`` 实际上不需要上述手工配置 ``mpd.conf`` ，因为只要系统中安装了 ``mpd`` ， ``cantata`` 启动时候就会自动引导你做一些简单配置(也就是选择音乐所在目录)，然后程序运行起来以后，你就会看到后台运行了一个 ``mpd`` 服务并且使用了 ``cantata`` 自动生成的 ``mpd.conf`` 配置文件。

简单来说， ``cantata`` 提供了自动配置 ``mpd`` 的功能来帮助你简化使用。不过，需要注意，在 :ref:`pi_400` 上必须使用 HDMI 作为音频设备，这个配置需要手工添加，见上文。

参考
======

- `MPD User's Manual <https://mpd.readthedocs.io/en/stable/user.html>`_
- `arch linux: Music Player Daemon <https://wiki.archlinux.org/title/Music_Player_Daemon>`_
- gemini
