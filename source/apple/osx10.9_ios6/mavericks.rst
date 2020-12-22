.. _mavericks:

====================================
Mac OS X 10.9.5 (Mavericks)使用体验
====================================

设置OS X
============

年齿渐长，老眼昏花，早期的MacBook Air 11不是Retina屏幕，加上屏幕窄小，所以看起来字体总有一些模糊，所以系统设置微调:

- ``System Preference > Displays`` 设置Resolution: Scaled 1280x720
- 在Safari的Perference中，调整Advanced面板中"Never user font size smaller than 14"，这样中文字体会稍微大一些

Xcode
=======

从 `Apple Developer网站 <https://developer.apple.com>`_ 可以下载到Xcode 6.1.1 版本，这对在Mac OS X 10.9.5上探索开发非常有用，建议安装。并且Homebrew也倚赖Xcode command Tools支持，如果使用gcc学习编程，也需要Xcode支持。

安装顺序是先安装Xcode，再安装Homebrew，然后再安装GNU工具软件。此外，作为终端，强烈推荐采用iTerm2替代系统默认的Terminal。

Python
=======

从 `Python官方下载Python Releases for Mac OS X <https://www.python.org/downloads/mac-osx/>`_ ，当前稳定版本 3.8.1 支持 Mac OS X 10.9。

Visual Studio Code
====================

最新版本VSC不能在Mac OS X 10.9上运行

Homebrew
=============

:ref:`homebrew` 是macOS必备工具，可以安装大量的GNU/Linux工具。

Homebrew安装过程需要从GitHub上下载源代码，但是GitHub的证书识别错误::

   fatal: unable to access 'https://github.com/Homebrew/homebrew-core/': SSLRead() return error -9806
   Error: Fetching /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core failed!

这个问题在早期Mac OS X上都存在，例如 `Git Clone Fails with sslRead() error on OS X Yosemite <https://www.howtobuildsoftware.com/index.php/how-do/ugg/git-curl-openssl-osx-yosemite-gitlab-git-clone-fails-with-sslread-error-on-os-x-yosemite>`_ 。参考 `Homebrew tutorial:How to use Homebrew for MacOS <https://www.infoworld.com/article/3328824/homebew-tutorial-how-to-use-homebrew-for-macos.html>`_ ，对于使用PPC版本OS X或者地版本OS X(Tiger/ Leopard)可以尝试  `Tigerbrew
<https://github.com/mistydemeo/tigerbrew>`_

应用软件
===========

MacBook Air 11-inch, Late 2010 ，十年前的产品，虽然宝刀不老，但是应用程序需要仔细甄选，因为很多软件已经没有适配早期 OS X 10.9.x版本了。好在一些经典软件依然可用，并且我主要把这台轻巧的笔记本作为移动终端，重负荷的编译、开发、虚拟化等都在远程服务器上完成。

Firefox
---------

虽然chrome目前受到的支持更广泛，但是最新的chrome需要Mac OS X 10.10，所以我改为采用Firefox，以便解决低版本Safari无法访问部分网站的问题。

Chrome
-----------

从网上找兼容版本:

- uptodown网站可以找到Chrome的历史版本 `Google Chrome for mac <https://google-chrome.en.uptodown.com/mac/versions>`_
- slimjet.com网站提供Chrome历史版本 `Google Chrome Older Versions Download (Windows, Linux & Mac) <https://www.slimjet.com/chrome/google-chrome-old-version.php>`_ chrome_67.0.3396.79.dmg 实测可以使用

.. note::

   参考 `Last version of Chrome for Mavericks 10.9.5? <https://forums.macrumors.com/threads/last-version-of-chrome-for-mavericks-10-9-5.2188544/>`_ 有介绍，可能最高可以使用 ``chrome 67.0.3396.99`` 或者 ``chromium 68.0.3398.0`` (chromium可以从 `GitHub的macchrome/chromium <https://github.com/macchrome/chromium/>`_ 下载 ) 。

iTerm2
----------

iTerm2 比系统自带Terminal要好用很多，选择 `iTerm2 3.0.13 (OS 10.8+) <https://iterm2.com/downloads/stable/iTerm2-3_0_13.zip>`_

- MacBook Air 11-inch 屏幕比较小，需要选择大一号字体(13pt Monaco)

KeePassXC/KeePassX
--------------------

开源账号密码管理工具KeePassXC (从Linux平台KeePassX fork)，不过最新版本也需要较高的macOS版本。我尝试安装没有特定macOS版本要求的 ``.dmg`` 但是无法启动。

可能需要尝试通过Homebrew安装::

   brew cask install keepassxc

目前暂时采用 `KeePassX v2.0.3 for Mac OS X <https://www.keepassx.org/downloads>`_ 。 （两者兼容）

WeChat(微信)
--------------

在AppStore和微信官网下载的WeChat版本2.3.29，需要 10.10 (Mavericks) 才能运行，所以无法在Mac OS X 10.9.5上安装。

变通方法可以采用:

- 使用 `微信网页版 <https://wx.qq.com/>`_ 对于我来说已经足够，因为我使用微信不频繁，主要是为了解决手机输入效率低的问题。不需要安装应用，只是需要通过Firefox使用(Mac OS X 10.9.5自带Safari不能支持)
  - 微信网页版在Firefox中使用时左侧导航栏无法滚动，这个限制导致使用不便
- `electronic-wechat <https://github.com/geeeeeeeeek/electronic-wechat/releases>`_ ，可以跨平台使用的微信版本，是通过Electron实现的网页版本，只是比较占用磁盘。
- `旧版本WeChat1.0 <https://pan.baidu.com/s/1c1XXs8C>`_ - 实践发现可以启动，但是通过扫描二维码登录失败(或许今后可以尝试采用6.1.3 iOS的微信)

.. note::

   很遗憾，阿里的钉钉无法在旧版本Mac OS X上运行，暂时也找不到可用的旧版。

VLC(开源视频播放器)
----------------------

虽然 `IINA开源视频播放器 <https://iina.io>`_ 非常完美，但是要求最新的macOS支持，无法在我的怀旧Mac OS X 10.9.5上运行。所以，改为选择 `VLC for Mac OS X <https://www.videolan.org/vlc/download-macosx.html>`_

参考
=====

- `Installing Homebrew on macOS Catalina 10.15, Package Manager for Linux Apps <https://coolestguidesontheplanet.com/installing-homebrew-on-macos-sierra-package-manager-for-unix-apps/>`_
