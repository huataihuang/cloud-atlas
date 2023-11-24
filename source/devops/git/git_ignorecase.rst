.. _git_ignorecase:

============================
git默认不区分文件名大小写
============================

我在排查 :ref:`readthedocs_slow_builds` 时，意外发现RTD编译的时候，提示了一个文件不存在的错误::

   ... WARNING: Include file '... mysql/installation/install_mariadb/yum_install_MariaDB' not found or reading it failed

但是我在自己的本地电脑上 ``make html`` 没有报错，并且我检查了该 ``install_mariadb/`` 目录:

.. literalinclude:: git_ignorecase/ls_output
   :caption: 检查 ``install_mariadb/`` 目录下文件
   :emphasize-lines: 9,10

可以看到一个微妙的差别，有两个类似文件名，区别仅是字母大小写区别

检查GitHub仓库，果然发现这两个同名但字母大小写差异的文件，只上传成功了一个:

.. figure:: ../../_static/devops/git/git_ignorecase.png

   对于仅有大小写区别的同名文件，git只会上传一个

解决方法
==========

如果确实想要通过文件名大小写来区别文件，并且让 ``git`` 能够识别，则需要修订 ``git`` 配置，设置对文件名大小写敏感:

.. literalinclude:: git_ignorecase/git_ignorecase_false_config
   :caption: 配置git能够区分文件名大小写

另一种方法就是严格规范文件名命名，禁止只有大小写区别的同名文件 

参考
======

- `解决 Git 默认不区分文件名大小写的问题 <https://www.jianshu.com/p/df0b0e8bcf9b>`_
