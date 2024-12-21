.. _install_jellyfin_pi:

=======================
在树莓派上安装Jellyfin
=======================

我的实践是在 :ref:`pi_5` 上完成，也就是ARM版本的 :ref:`debian` ( :ref:`raspberry_pi_os` ):

.. literalinclude:: install_jellyfin_pi/debian
   :caption: Debian系安装Jellyfin

经过验证，在树莓派上安装是非常丝滑的过程，会自动添加仓库配置，安装依赖并完成安装，最后会启动服务，并在终端输出提示，即提示通过浏览器访问 http://<server_ip>:8096 就可以按照提示完成初始配置(设置管理账号)

使用体验
=========

简单来说就是添加一个Libraries(媒体库)就可以开始播放(通过浏览器)，不过，目前我还没有仔细阅读文档，感觉使用上有一些出乎我的经验的地方:

- 支持直接添加媒体路径到Liraries中构成一个播放入口，这个服务器端的Path中，我存放了 `百年孤独(Netflx) <https://movie.douban.com/subject/30482958/>`_ 第一季，但是我不知道如何能设置好列出完整列表
- 支持MKV直接播放，播放时能够选择声道、字幕，所以非常适合对自己保存的大量视频进行整理作为家庭影院使用

后续我会继续探索部署和管理，以便能够结合 :ref:`nginx` / :ref:`proxy` 等构建一个视频网站模拟。待续...

参考
=====

- `Jellyfin Installation > Linux#debian <https://jellyfin.org/docs/general/installation/linux#debian>`_
