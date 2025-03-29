.. _intro_hostap:

========================
HostAP简介
========================

HostAP
===========

``HostAP`` 是Linux的IEEE 80.211 设备驱动，它适用于使用过时的Conexant(以前称为Intersil) Prism 2/2.5/3 芯片组的网卡，并支持Host AP模式，这样无线网卡就能作为无线AP来使用。HostAP驱动代码由Jouni Malinen编写，并在Linux 2.6.14时引入到内核主线。

.. warning::

   根据 `HostAP维护者申明，2016年9月开始，内核HostAP 驱动已经被标记为过时 <https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?id=ffd74aca44b70a2564da86e8878c1dd296009ffb>`_ ，后续 ``需要采用替代hostap的解决方案``

.. _hostapd:

hostapd
===========

``hostapd`` (host access point daemon) 即主机无线AP服务，是一个将主机网卡作为无线AP和认证服务器的用户空间daemon，一共有3个实现:

- `Jouni Malinen's hostapd <https://w1.fi/hostapd/>`_ 可参考内核无线文档 `hostapd Linux documentation page <https://wireless.wiki.kernel.org/en/users/documentation/hostapd>`_
- OpenBSD's hostapd
- Devicescape's hostapd

Jouni Malinen's Hostapd
--------------------------

**这应该是我们最常使用的Linux上HostAP管理工具**

无线软件堆栈指南
==================

`Infineon英飞凌公司 <https://www.infineon.com/>`_ (前身是西门子半导体，1999年独立。无线解决方案部于2010年8月出售给intel) 在开发社区知识库提供了一片非常详尽的 `HostApd setup in Linux <https://community.infineon.com/t5/Knowledge-Base-Articles/HostApd-setup-in-Linux/ta-p/246026#.>`_ ，这篇文档属于英飞凌公司提供的 `AN232689 - Wi-Fi software user guide <https://www.infineon.com/dgdl/Infineon-AN232689_-_Wi-Fi_software_user_guide-ApplicationNotes-v01_00-EN.pdf>`_ (非常专业和详尽的Linux无线软件堆栈指南) 的 4.2 章节。

参考
=========

- `Wikipedia: HostAP <https://en.wikipedia.org/wiki/HostAP>`_
- `Wikipedia: hostapd <https://en.wikipedia.org/wiki/Hostapd>`_
