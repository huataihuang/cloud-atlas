.. _rpm:

==============
rpm包管理器
==============

检查安装rpm保重的运行脚本
===========================

rpm包中会包含一些脚本，有时候需要检查脚本以确定安装软件的前后执行的脚本运行情况::

   rpm -qp --scripts filename.rpm

对于已经安装好的软件包，也可以检查脚本::

   rpm -q --scripts packageName

rpm的spec配置
================

有时候你需要制作一个rpm包，需要参考以下类似软件的打包spec文件。此时可以使用 ``rpmrebuild`` 工具提取::

   rpmrebuild --package --notest-install -e oracle-instantclient-basic-10.2.0.4-1.x86_64.rpm
   rpmrebuild -s hercules.spec hercules

这样就可以从现有下载的rpm中或者已经安装的软件获取原始的spec文件

rpm检查依赖包
===============

如果要检查软件包依赖，可以使用::

   rpm -q --requires xmms

或者使用::

   rpm -qR xmms

检查rpm所有安装的文件列表
==========================

- 列出所有安装文件::

   rpm -ql BitTorrent

检查最近安装的rpm包
=====================

- 显示最近安装的包::

   rpm -qa --last

- 显示所有安装包::

   rpm -qa

检查一个文件属于哪个rpm包
===========================

- 例如检查passwd文件属于哪个包::

    rpm -qf /usr/bin/htpasswd

检查rpm包的信息
================

- 输出rpm包的详细信息::

   rpm -qi vsftpd

   rpm -qip sqlbuddy-1.3.3-1.noarch.rpm

检查已经安装的软件包的文档
============================

::

   rpm -qdf /usr/bin/vmstat

校验rpm包
===========

::

   rpm -Vp sqlbuddy-1.3.3-1.noarch.rpm

导入rpm的GPG key
===================

::

   rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

重建损坏的RPM包信息
====================

::

   cd /var/lib
   rm __db*
   rpm --rebuilddb
   rpmdb_verify Packages

rpm版本降低
============

对于已经安装了高版本的软件包，需要降级版本，则需要使用参数 ``--oldpackage`` ，这样就允许安装旧版本。

要注意使用 ``-U`` 参数，这样就是 ``upgrade`` ，就会替换另一个版本。如果使用 ``-i`` 参数替代 ``-U`` ，则会导致 **同时** 安装两个版本。

::

   rpm -Uvh --oldpackage [filename]

也可以使用 ``yum downgrade packagename`` 

参考
======

- `Linux RPM: View Script That Run When You Install RPM Files <https://www.cyberciti.biz/faq/centos-rhel-suse-rpm-see-installation-uninstallation-scripts/>`_
- `extract the spec file from rpm package <http://stackoverflow.com/questions/5613954/extract-the-spec-file-from-rpm-package>`_
- `How to extract spec file from rpm file <http://www.linuxquestions.org/questions/programming-9/how-to-extract-spec-file-from-rpm-file-426847/>`_
- `How do I downgrade an RPM? <http://serverfault.com/questions/274310/how-do-i-downgrade-an-rpm>`_
