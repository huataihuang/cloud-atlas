.. _introduce_tails_linux:

===================
Tails Linux简介
===================

Tails Linux是著名的 `第四公民 Citizenfour (2014) <https://movie.douban.com/subject/26059437/>`_ 斯诺登所使用的操作系统( `Out in the Open: Inside the Operating System Edward Snowden Used to Evade the NSA <https://www.wired.com/2014/04/tails/>`_ )，他在和报道记者合作时使用该系统，为这个神秘的操作提供提供了有力的背书。

.. note::

   斯诺登通过匿名优化的Tails来避免被跟踪，同时使用PGP电子邮件加密软件进行所有通信。

Tails是一种 ``computer-in-a-box`` ，也就是通过DVD或U盘启动系统，针对匿名性进行优化的Linux系统。Tails提供来集中隐私和加密工具:

- Tor: 将用户的互联网流量路由到世界各地的志愿者运行的计算机网络来匿名化用户的互联网流量

  - Tor项目为Tails提供了项目初期的开发资金(开放技术基金、Mozilla和新闻自由基金会也资助了Tails)
  - 2024年9月26日，Tails项目和Tor项目合并，Tails专注于维护和改进Tails OS，同时受益于Tor项目更大的组织结构

Tails现在基于 :ref:`debian` 开发:

- 从2017年的release 3.0开始，必须在64位处理器上运行
- Tails包含独特的软件来处理文件和互联网传输的加密、加密签名和散列、Electrum比特币钱包、Aircrak-ng和其他对安全很重的功能
- 预先配置并尝试强制所有连接使用Tor并组织Tor之外的连接尝试

  - 采用Tor浏览器的修改版本(包含uBlock Origin插件进行内容过滤，包含阻止广告)
  - 即时消息、电子邮件、文件传输和监控本地网络以确保安全

- 采用"健忘"设计(amnesic):

  - 在RAM中运行，不会写入磁盘或其他存储介质
  - 用户可选择将文件、应用程序或某些设置保存在Tails驱动器的"持久存储"中(默认加密，但不会被隐藏，也无法通过取证分析检测到)
  - Tails关闭时会覆盖大部份使用的RAM以避免冷启动攻击

.. note::

   2017年FBI通过Facebook开发的恶意代码，通过默认视频播放器中的0-day漏洞识别处性勒索者和Tails用户Buster Hernandez。

   据信该漏洞已经在Tails后续版本中得到修补。

.. note::

   另一个得到斯诺登称赞的安全操足系统是 :ref:`qubes_os` : 一个通过虚拟化技术提供隔离提供安全性的以安全为中心的桌面操作系统。

参考
======

- `Tails Linux (A Tor Linux Distro) – An Ultimate Guide <https://howtouselinux.net/tails-linux/>`_
- `WikiPedia: Tails(operating system) <https://en.wikipedia.org/wiki/Tails_(operating_system)>`_
