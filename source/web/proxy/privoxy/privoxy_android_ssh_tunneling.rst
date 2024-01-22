.. _privoxy_android_ssh_tunneling:

===============================
Privoxy Android SSH Tunneling
===============================

最近想要解决自己的 :ref:`pixel_4` 手机 :ref:`across_the_great_wall` 问题，但是又没有时间重新部署 :ref:`openconnect_vpn` 。我忽然想到，既然我的Android系统安装了 :ref:`termux` ，实际上手机就是一个完整的Linux系统，何不类似电脑一样，采用 :ref:`ssh_tunneling_dynamic_port_forwarding` 实现一键翻墙呢？

.. note::

   Android系统网络配置中可以设置代理，但是这个代理仅限于 HTTP/HTTPS 代理，也就是说无法直接使用 :ref:`ssh_tunneling_dynamic_port_forwarding` 创建的 Socks5 代理。所以，这里才会引入一个简洁的 :ref:`privoxy` 代理服务器，作为中间转接。

``ssh + privoxy``
===================

- :ref:`termux_install` 后安装 ``openssh`` :

.. literalinclude:: ../../../android/apps/termux_install/openssh
   :caption: termux中安装 openssh

- 配置 ``.ssh/config`` 设置 :ref:`ssh_multiplexing` 以便能够一次登录多次复用连接:

.. literalinclude:: ../../../infra_service/ssh/ssh_multiplexing/ssh_config
   :language: bash
   :caption: 配置所有主机登陆激活ssh multiplexing,压缩以及不检查服务器SSH key(注意风险控制)

- 安装 :ref:`privoxy` :

.. literalinclude:: privoxy_android_ssh_tunneling/install_privoxy
   :caption: 在Android的 :ref:`termux` 中安装privoxy

默认安装后，配置文件位于 ``~/../usr/etc/privoxy`` 目录下的 ``config`` 文件，默认配置就可以运行。

配置socks上游代理
====================

既然我们已经构建了 :ref:`ssh_tunneling_dynamic_port_forwarding` ，也安装好了 :ref:`privoxy` ，接下来就需要配置 ``privoxy`` 代理转发到Socks5:

- 修改  ``~/../usr/etc/privoxy/config`` 配置文件，在最后添加以下配置表示允许本地访问(回环地址拒绝外部访问)以及将访问转发到本地的 Socks5 代理服务器( :ref:`ssh_tunneling_dynamic_port_forwarding` ) 上:

.. literalinclude:: privoxy_android_ssh_tunneling/privoxy_config
   :caption: ``~/../usr/etc/privoxy/config`` 配置转发上游Socks5代理服务器

- 使用如下命令启动 ``privoxy`` (建议在 :ref:`tmux` 或 :ref:`screen` 中运行):

.. literalinclude:: privoxy_android_ssh_tunneling/run_privoxy
   :caption: 运行 ``privoxy``

- 一切就绪，现在只需要配置 Android 系统使用 ``127.0.0.1:8118`` 作为代理服务器就可以 :ref:`across_the_great_wall`  

待改进
============

不足待改进:

- Android提供了WLAN配置(WiFi)使用代理，但是没有提供移动网络的配置，所以上述方法在使用4G/5G移动网络时无效。不过，我想到一个改进方案 :ref:`privoxy_transparent_proxy_alpine` (待实践)
- 需要有一个按需代理的配置方法，方便用户输入不同需要代理翻墙的地址，类似 :ref:`firefox` 和 :ref:`chrome` 常用的插件 ``SwitchyOmega``

参考
=========

- `PrivoxyAndroid-Tutorial <https://github.com/gauravssnl/PrivoxyAndroid-Tutorial>`_
