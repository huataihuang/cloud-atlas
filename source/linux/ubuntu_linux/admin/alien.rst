.. _alien:

====================
alien软件包转换工具
====================

在Linux发行版中， Debian/Ubuntu 和 RedHat RHEL/CentOS/Fedora/SuSE 是两大软件包体系。但是也带来了分裂，有些社区软件包只提供了deb包，而有些企业软件缺又只提供rpm包。实际上，主流Linux发行版内核和运行库并没有太大区别，很多软件只是打包方式不同(开发测试环境不同)，实际上能够在不同发行版上运行。所以，我们需要有一个管理工具来进行软件包的转换，这就是 ``alien`` 。

常用DEB<=>RPM转换
==================

- 转换RPM到DEB::

   alien linuxconf-devel-1.16r10-2.i386.rpm

- 转换DEB到RPM::

   sudo alien -r libsox1_14.2.0-1_i386.deb

可以看到， ``alien`` 主要是面向Debian/Ubuntu，所以不需要任何参数就可以转换rpm包到deb；但是反过来转换deb到rpm时候需要使用参数 ``-r``

转换成SLP，LSB，Slackware TGZ包
================================

alien工具提供了强大的不同格式软件包转换，使用 ``-h`` 参数查看可以知道::

   -d, --to-deb              Generate a Debian deb package (default).
   -r, --to-rpm              Generate a Red Hat rpm package.
       --to-slp              Generate a Stampede slp package.
   -l, --to-lsb              Generate a LSB package.
   -t, --to-tgz              Generate a Slackware tgz package.

参考
=======

- `How to Convert DEB to RPM (RPM to DEB) Package Using Alien Command <https://www.thegeekstuff.com/2010/11/alien-command-examples/>`_
