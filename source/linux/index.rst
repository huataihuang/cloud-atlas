.. _linux:

=================================
Linux Atlas
=================================

Linux是运计算的主流基础操作系统，除了微软的Azure，其他主要的运计算服务商(Amazon AWS, Goolgle Cloud, Alibaba Cloud ...)都构建在各自定制的Linux上。

我个人使用过不同的Linux发行版，虽然各个发行版有各自独特的包管理方式，部分软件的配置惯例有所区别，但总体上技术是相通的。所以在本书「Linux Atlas」撰写中，虽然分了不同的分册面向不同的发行版，但只是因为我在实践过程中恰好使用这个发行版而已。绝大多数的经验技能都可以通用。

从 `W3Techs的年度WEB网站Linux统计 <https://w3techs.com/technologies/history_details/os-linux/all/y>`_ Ubuntu使用率最高，这应该和Ubuntu社区活跃安装使用方便有关，其次是CentOS则在大型互联网公司使用较为广泛。总体来说，熟悉这两种主流发行版本对于Linux工作还是非常不要的。知乎上 `互联网公司选择 Debian、Ubuntu 和 CentOS 哪一个发行版运维成本最低? <https://www.zhihu.com/question/29195044/answer/865305122>`_
同样引用了W3Techs的报告，可以看出:

- Ubuntu使用的网站数量高于CentOS，但是更多的网站使用的是Windows以及Unix系统，不过总体来看在Linux范围内Ubuntu的市场份额是CentOS的2倍
- 大型互联网公司使用CentOS/Ubuntu/Windows的比例差不多
- 综上：如果是小型互联网公司趋向于使用Ubuntu，大型互联网公司则两者基本持平

.. note::

   线路图

   :ref:`gentoo_linux` => :ref:`container_linux` => :ref:`chromium_os` => flint_os

.. toctree::
   :maxdepth: 1

   redhat_linux/index
   arch_linux/index
   gentoo_linux/index
   lfs_linux/index
   ubuntu_linux/index
   suse_linux/index
   kali_linux/index
   tails_linux/index
   postmarketos/index
   container_os/index
   chromium_os/index
   container_linux/index
   alpine/index
   subgraph_os/index
   compute/index
   storage/index
   network/index
   server/index
   security/index
   desktop/index

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
