.. _archlinux_vultr:

==============================
在Vultr VPS中运行Arch Linux
==============================

最近把购买的Vultr VPS转到硅谷机房，发现Vultr提供了多种操作系统可选，甚至还提供了自己上传iso镜像( 试试 :ref:`gentoo_linux` ? )。我考虑尝试更新的技术，所以将使用了4年的Ubuntu VPS改成Arch Linux。这里记录在云厂商Vultr上部署Arch Linux的过程。

选购和访问
============

家里使用的是移动提供的宽带，我经过对比发现Vultr的硅谷机房访问最稳定，速度也最快。购买Vultr最便宜的5美刀VPS，作为翻墙和简单WEB网站已经足够。启动新创建的Arch Linux VPS，登陆后检查可以看到 24GB 的 ``/dev/vda2`` 已经用去了 4.5G:

.. literalinclude:: archlinux_vultr/df
   :caption: Vultr的arch linux初始使用容量
   :emphasize-lines: 4

系统配置
========

- 默认时区修订成中国:

.. literalinclude:: ../../infra_service/ntp/host_time_init/local_timezone.sh
   :language: bash
   :caption: 配置上海本地时区
