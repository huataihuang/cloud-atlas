.. _solaris:

=============
Solaris
=============

Solaris是计算机历史上传奇的操作系统，由SUN公司(发明了Java)开发，曾经一度是数据中心举足轻重的基石。然而，先进的技术没有良性的商业运作和完善的开源社区支持，难免最终称为历史。不过，Solaris在最后的发展阶段(被Oracle收购之前)，终于拥抱了开源，推出了影响业界的 OpenSolaris/illumos 系统，并衍生出至今仍在活跃开发的开源分支( `OpenSolaris发展历史 <https://jimgrisanzio.wordpress.com/opensolaris/>`_ )：

- openindiana - 基于illumos(操作系统核心软件组合)开发的操作系统
- :ref:`omnios` - 通用型服务器操作系统(基于illumos)，和smartos类似也支持容器和KVM
- :ref:`smartos` - 专注于云计算的分支(内存运行操作系统)，结合了容器技术和KVM(开发公司是Jeyent，也是最早支持和开发node.js的公司)

.. note::

   :ref:`smartos` 是一个特别的发行版，专注于云计算，有些类似Red Hat推出的 :ref:`container_linux` ，并非通用操作系统。但是在专有领域，通过精简和定制能够更高效地运行虚拟机和容器。

   如果作为通用服务器操作系统，推荐采用 :ref:`omnios` 和 openindiana (也是illumos推荐)

参考
=======

- `Comparison of OpenSolaris distributions <https://en.wikipedia.org/wiki/Comparison_of_OpenSolaris_distributions>`_
