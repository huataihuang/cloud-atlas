.. _intro_jellyfin:

==============
Jellyfin简介
==============

`Jellyfin开源项目 <https://jellyfin.org>`_ 是媒体系统自由软件，是服务器端管理媒体和流媒体播放的服务系统。Jellyfin源自Emby 3.5.2版本(Emby从3.5.2开始从开源转为闭源)，并移植到 .NET Core框架以实现完全的跨平台支持。Jellyfin是无安全开源软件，没有附加条件和高级许可证，专注于构建更好的开源系统。

Jellyfin功能:

- 可以支持DLNA和Chromecast的设备提供媒体

其他类似开源项目
==================

开源视频软件众多，但是对比之下我发现绝大多数开源媒体软件的定位和Jellyfin都不同，大多是实现桌面播放(LVC)或作为类似智能电视的媒体中心(如 :ref:`kodi` )，所以通常并没有提供API以及WEB浏览器访问。和Jellyfin定位相同的开源软件是 ``Kyoo`` ( `GitHub: zoriya/Kyoo <https://github.com/zoriya/Kyoo>`_ )，但是Kyoo的发展不如Jellyfin:

- Jellyfin是使用更为广泛和更受欢迎的开源媒体服务器，GitHub Star高达4.1w，远超Kyoo 2.1k Star(两个开源项目相隔1年创建，其实历史相近)
- Jellyfin和Kyoo的软件栈类似，核心都采用了C#(.NET Core framework)，都提供了WEB浏览器访问
- 软件的设计架构有所区别:

  - Jellyfin提供了插件扩展
  - Kyoo是一个完全自包含的系统，即集成所有功能而不提供插件系统

.. note::

   虽然我在开始使用Jellyfin的时候不太顺利，但是考虑到Jellyfin使用广泛以及社区支持活跃，所以我会继续探索Jellyfin的部署和使用

参考
=======

- `Jellyfin开源项目 <https://jellyfin.org>`_ 开源(GPL)媒体系统
- `Jellyfi文档 <https://jellyfin.org/docs/>`_
