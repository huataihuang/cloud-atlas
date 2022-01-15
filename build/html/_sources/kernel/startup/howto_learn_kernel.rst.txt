.. _howto_learn_kernel:

=======================
如何学习Linux内核
=======================

Linux学习是一个登山的过程，道路曲折，路径繁杂，但最终都会归结到内核。个人认为，越是底层的技术发展路径越稳定，只要有恒心和毅力，有无穷的探索可以让你乐此不疲。

就像Linus说的， `Just for Fun <https://www.amazon.com/Just-Fun-Story-Accidental-Revolutionary/dp/0066620732/>`_ 。

Linux系统编程
=================

Linux系统编程指开发底层软件，例如存储或网络应用程序。

系统编程和大多数应用开发不同，包含了大量的OS和网络内容。你需要了解详细的 `Linux Kernel Interface <https://en.wikipedia.org/wiki/Linux_kernel_interfaces>`_ 。由于历史和性能原因，Linux系统编程通常需要掌握 C/C++ 以及由C提供的系统API。

系统编程需要gdb debugging技能，推荐参考书籍:

- `Debugging with GDB: The GNU Source-Level Debugger <https://www.amazon.com/Debugging-GDB-GNU-Source-Level-Debugger/>`_

- :ref:`valgrind` 是常用的内存检查工具。

系统编程推荐书籍：

- `Linux System Programming: Talking Directly to the Kernel and C Library <https://www.amazon.com/Linux-System-Programming-Talking-Directly/>`_ 对应中文版 `Linux系统编程（第2版） <https://www.amazon.cn/dp/B075R6LTL3/>`_
- `The Linux Programming Interface: A Linux and UNIX System Programming Handbook <https://www.amazon.com/Linux-Programming-Interface-System-Handbook/dp/1593272200/>`_ 对应中文版 `Linux/UNIX系统编程手册（上、下册） <https://www.amazon.cn/dp/B075R5LCFY/>`_ (参考手册)
- `Unix Network Programming: The Sockets Networking Api <https://www.amazon.com/Unix-Network-Programming-Sockets-Networking/dp/0131411551/>`_ 对应中文版 `UNIX网络编程 卷1 套接字联网API 第3版 <https://item.jd.com/12715718.html>`_ (找不到亚马逊中国的Kindle页面了，之前可以购买)
  
传统上系统编程需要深入学习C/C++，近年来技术发展新一代系统编程语言可以采用Rust/Python。不过，C/C++依然是主流。

需要学习非常广泛的知识领域， `To Be A Great Programmer: Mindset And Learning Strategy <https://coderscat.com/to-be-a-programmer/>`_ 介绍了一些心得，也许你需要沉下心自我学习训练10年 - `Peter Norvig: Teach Yourself Programming in Ten Years <https://norvig.com/21-days.html>`_

内核开发
=============

Linux内核包含了非常多的模块，例如内存管理，进程调度，虚拟内存，文件系统，设备驱动等等。

.. figure:: ../../_static/kernel/startup/linux-kernel-map.png
   :scale: 65

这么多内容对于内核开发初学者来说可能会感觉无从下手，所以你需要一个关于内核的全景指引：

- Robot Love 撰写的 `Linux Kernel Development <https://www.amazon.com/Linux-Kernel-Development-Developers-Library-ebook-dp-B003V4ATI0/dp/B003V4ATI0/>`_ 是最佳的入门书籍

其他有关内核开发的推荐书籍：

- `Modern Operating System <https://www.amazon.com/Modern-Operating-Systems-Andrew-Tanenbaum/dp/013359162X/>`_ 对应中文版 `现代操作系统 <https://item.jd.com/12139635.html>`_ (只有纸版书，没有Kindle)
- `Understanding the Linux Kernel <https://www.amazon.com/Understanding-Linux-Kernel-Third-Daniel/dp/0596005652/>`_ 对应中文版 `深入理解Linux内核(第3版) <https://item.jd.com/10100237.html>`_ (只有纸版书，没有Kindle)
- `Professional Linux Kernel Architecture <https://www.amazon.com/Professional-Kernel-Architecture-Wolfgang-Mauerer/dp/0470343435/>`_ 对应中文版 `深入Linux内核架构 <https://www.amazon.cn/dp/B00CBBJVXI/>`_

需要注意的是，Linux内核开发的领域太多了，对于初学者不可能同时学习所有领域，所以学习的策略是：

- 首先获得Linux内核的概况，推荐上文介绍的 Robot Love 撰写的 `Linux Kernel Development <https://www.amazon.com/Linux-Kernel-Development-Developers-Library-ebook-dp-B003V4ATI0/dp/B003V4ATI0/>`_
- 另一种可行的方法是学习旧版本Linux，这是因为旧版本代码较少，可以较快完成学习。
- `xv6 <https://pdos.csail.mit.edu/6.828/2012/xv6.html>`_ 是另外一种学习方法，采用简化的UNIX教学操作系统，是MIT操作系统课程 `6.828: Operating System Engineering <http://pdos.csail.mit.edu/6.828>`_ 的教学用软件。并且提供了 `6.828: Operating System Engineering学习阅读资料 <https://pdos.csail.mit.edu/6.828/2019/reference.html>`_
- 你应该集中精力先学习一个感兴趣的子系统，理解原理并尝试设计。尝试加入内核开发社区，阅读 `Kernel Howto文档 <https://www.kernel.org/doc/html/v4.16/process/howto.html>`_ ，加入 `Linux邮件列表 <https://lkml.org/>`_ ，review其他人的补丁并尝试自己提交补丁。Linux内核社区由自己的写作方式，需要学习规则。当你的第一个补丁被接受，这将是一个巨大的里程碑。此外，当你具备了某个内核子系统的足够知识和技能，就会非常容易转换到另一个子系统。

你需要花费很多年来掌握内核编程，所以 ``happy hacking, and have fun`` 。

.. note::

   很遗憾，国内没有引进 `Linux Kernel Development <https://www.amazon.com/Linux-Kernel-Development-Developers-Library-ebook-dp-B003V4ATI0/dp/B003V4ATI0/>`_ ，请参考 `Linux.Kernel.Development.3rd.Edition.pdf <https://github.com/jyfc/ebook/blob/master/03_operating_system/Linux.Kernel.Development.3rd.Edition.pdf>`_

代码注释、调试和参与社区
=========================

学习内核代码是一个漫长的过程，系统越来越复杂和庞大。老内核开发和新加入的开发之间存在不同的知识边界，相互间存在 ``代沟`` 。解决的方法可能是:

- 保持代码清晰：明确的接口，稳定的设计，以及 "只做一件事，将事情做好" (Linus Torvald的解决方案)
- 代码注释是开发者和后来维护者的沟通途径，你需要理解设计和实现之间的差异(也就是debuging)，你通过修改内核代码来能够理解内核设计，并且远比仅仅阅读代码要理解得更为深刻
- 加入内核开发邮件列表并和其他开发者互动，这会促使你和其他开发者共同进步

参考
=========

- `How to Learn Linux? (from Zero to Hero) <https://coderscat.com/how-to-learn-linux/>`_ 这是一篇关于如何学习Linux的经验分享，涵盖了 ``维护、应用开发、系统编程、内核开发`` 的一些建议。本文摘自其中的系统编程和内核开发部分，觉得有所借鉴
- Robot Love 撰写的 `Linux Kernel Development <https://www.amazon.com/Linux-Kernel-Development-Developers-Library-ebook-dp-B003V4ATI0/dp/B003V4ATI0/>`_
