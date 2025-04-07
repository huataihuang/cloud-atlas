.. _intro_qubes_os:

=====================
Qubes OS简介
=====================

Qubes OS和 :ref:`tails_linux` 都是面向安全设计开发的操作系统，但是有着显著不同:

- Qubes OS主要假设攻击来自互联网，并没有像Tails假设你是用的笔记本会被物理接触破解(Tails 不保存任何本地数据，用后即焚)，所以主要通过虚拟机来隔离不同的使用场景，以确保某个场景被攻破后依然保持操作系统的其他部分安全
- 底层使用 :ref:`xen` 虚拟化技术来隔离不同的使用操作系统( :ref:`fedora` , :ref:`debian` 和 :ref:`windows` )
- 设置不同的信任级别，所有的窗口都显示在一个统一桌面环境，并使用不同的颜色窗口边界来区分不同的安全级别

.. figure:: ../../_static/linux/qubes_os/qubes-trust-level-architecture.png

   Qubes OS架构
   

参考
=======

- `WikiPedia: Qubes OS <https://en.wikipedia.org/wiki/Qubes_OS>`_
- `What is Qubes OS? <https://www.qubes-os.org/intro/>`_
