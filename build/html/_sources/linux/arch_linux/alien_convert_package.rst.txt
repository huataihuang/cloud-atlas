.. _alien_convert_package:

==================
alien转换安装包
==================

很多时候提供的第三方软件包使用的是发行版相关的打包格式，例如Red Hat rpm，Debian deb, Slackware tgz, Solaris pkg等。但是如果要安装到和软件包格式不同的系统中，则需要alien转换包格式，例如，deb包转换成rpm或tgz。

.. note::

   如果要转换rpm包或转换成rpm包，则系统中需要先安装rpm工具。

   不要转换系统安装包，往往会存在问题。

参数:

====== ==================================================
参数   说明
====== ==================================================
-d     制作debian包，这是默认选项
-r     制作rpm包
-t     制作tgz包
-i     自动安装每个生成的包
-g     生成临时目录用于构建包，但不时间创建包
-c     尝试转换安装就爱哦本
--path 指定目录而不是自动查询包更新的/var/lib/alian
====== ==================================================

- 转换rpm::

   alien -r package.deb

- 转换deb::

   alien -d package.rpm

- 转换tgz::

   alien -t package.deb

参考
======

- `alien manual <http://manpages.ubuntu.com/manpages/bionic/man1/alien.1p.html>`_
