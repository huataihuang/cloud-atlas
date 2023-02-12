.. _intro_pentoo:

====================
Pentoo简介
====================

Pentoo是基于Gentoo Linux开发的渗透测试工具集，这个发行版一直在持续开发，主要是汇总不同的安全工具。不过，这个发行版没有提供详细的文档，所以如果要学习使用，主要还是要参考 :ref:`gentoo_linux` 和 :ref:`kali_linux` :

- 没有提供文档
- `Pentoo FAQs <https://www.pentoo.ch/faqs>`_ 其实非常简略，对于解释为何项目看上去像是死亡也只有一句hacker式的解释 ``Sorry, we’ve been busy compiling. :-)``

Pentoo Overlay
=================

Pentoo Overlay是在 :ref:`gentoo_linux` 安装以后提供的Overlay安装，并且可以制作 Live CD/USB 方便进行安全测试工作:

- 提供在wifi驱动上注入包补丁
- GPGPU破解软件
- 大量的渗透(penetration)测试和安全评估工具
- 内核包含了grsecurity和PAX hardening and extra patches
- 每天自动build发布Pentoo Livecd

参考
======

- `GitHub: pentoo/pentoo-overlay <https://github.com/pentoo/pentoo-overlay>`_
