.. _reduce_git_repo_size:

===================
缩减git仓库大小
===================

.. note::

   早期我为了方便部署sphinx doc撰写的Cloud Atlas，采用直接将 ``make html`` 输出的 ``build`` 目录直接提交到软件仓库，但是这带来了仓库的急剧膨胀。实际代码和图片近占用不到150MB，但是软件仓库反复build之后，达到了惊人的1.1GB。

   我在寻找方法清理不必要的磁盘占用，挖坑待实践

参考
======

- `Reduce git repository size <https://stackoverflow.com/questions/2116778/reduce-git-repository-size>`_
- `How can I know if 'git gc --auto' has done something? <https://stackoverflow.com/questions/45426297/how-can-i-know-if-git-gc-auto-has-done-something/64077241#64077241>`_
