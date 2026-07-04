.. _privoxy_calibre_translator_ssh_tunneling:

=========================================================
SSH Tunneling+privoxy为Calibre Ebook Translator提供梯子
=========================================================

我现在采用 :ref:`linuxserver_docker-calibre` 来运行自己的电子书管理平台，由于大量的电子书是英文原版，阅读非常花费精力，所以我采用 :ref:`calibre_ebook_translator` 。

问题在于Google Translator被GFW屏蔽了，需要 :ref:`across_the_great_wall` 才能运行，最简单的翻墙方式是使用 :ref:`ssh_tunneling_dynamic_port_forwarding` ，但是 `Ebook-Translator-Calibre-Plugin <https://github.com/bookfere/Ebook-Translator-Calibre-Plugin>`_ 支持的是HTTP Proxy，这就存在一个gap需要填平: 如何转换socks代理到HTTP代理?

`Privoxy无缓存web代理 <https://www.privoxy.org/>`_ 恰好就是这样一个功能简洁且符合要求的软件

安装
=======

:ref:`linuxserver_docker-calibre` 是在 :ref:`ubuntu_linux` 主机上运行的容器系统，那么最好的方式就是采用 :ref:`docker_compose` 结合 :ref:`calibre_kobo` , :ref:`privoxy` 和 :ref:`shadowrocket_ss` 实现完整的加密链路。


