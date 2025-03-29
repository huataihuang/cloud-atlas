.. _vim_fold:

====================
vim折叠
====================

语法折叠
=========

- 在 ``vimrc`` 中添加如下配置::

   set foldmethod = syntax

- 快捷键::

   zc 关闭折叠
   zo 打开折叠
   za 打开/关闭折叠互相切换

关闭vim默认折叠
===================

当选择好自动折叠以后，打开代码时候就会发现vim默认把所有代码都折叠了。如果不想要这个选项，可以在 ``vimrc`` 中添加如下配置关闭默认折叠::

   set foldlevelstart=99

参考
======

- `vim折叠快捷键 <https://www.cnblogs.com/zlcxbb/p/6442092.html>`_
- `vim折叠 <https://www.jianshu.com/p/16e0b822b682>`_

