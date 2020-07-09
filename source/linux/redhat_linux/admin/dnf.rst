.. _dnf:

================
DNF包管理器
================

DNF是在基于RPM的Linux发布版本中提供软件包管理器，提供自动计算软件包依赖和安装卸载，并且容易维护服务器组。从Fedora 18开始，DNF被引入，并从Fedora 22开始成为默认包管理器，取代了YUM。由于Red Hat Enterprise Linux 8基于Fedora 28，将全面转向使用DNF管理RPM。

.. note::

   在 CentOS 8中检查 ``yum`` 命令，可以看到上是 ``dnf`` 命令的软链接::

      $ ls -lh /usr/bin/yum
      lrwxrwxrwx. 1 root root 5 Dec 19 23:43 /usr/bin/yum -> dnf-3

DNF提供了YUM兼容的命令行以及为扩展和插件提供了精确的API。插件可以修改或者扩展DNF的功能或者提供附加的CLI命令。

DNF从Yum分支出来，使用专注于性能的C语言库hawkey进行依赖关系解析工作，大幅度提升包管理操作效率并降低内存消耗。DNF替代Yum的原因如下：

- Yum不能"Python 3 as default"，而DNF支持Python 2和Python3
- 启动DNF项目的原因是Yum的三个陷阱： ``undocumented API`` 、 ``broken dependency solving algorithm`` 和 ``inability to refactor internal functions`` 。Yum插件可以在Yum代码中使用任何method，这会造成Yum utility因一些细小变化而突然崩溃。
- DNF目标是为了避免Yum执行的错误。从一开始所有暴露的API都被适当的记录，且测试几乎包含了每一次新的提交。这个项目采用了敏捷开发，会提供用户一些优先级功能实现。

安装DNF包管理器
==================

- 在RHEL/CentOS 7中安装DNF需要先安装 ``epel-release`` ::

   yum install epel-release

或者参考 `Extra Packages for Enterprise Linux (EPEL) <https://www.fedoraproject.org/wiki/EPEL>`_ ::

   yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

- 然后安装 ``DNF`` 包::

   yum install dnf

DNF包管理器使用
==================

- 查看DNF包管理器的版本::

   dnf --version

- 查看系统中可用的DNF软件库::

   dnf repolist

- 查看系统中可用的和不可用的所有的DNF软件库::

   dnf repolist all

- 添加DNF Repository::

   dnf config-manager --add-repo repository_url

举例::

   dnf config-manager --add-repo http://www.example.com/example.repo

- 激活DNF Repository::

   dnf config-manager --set-enabled repository…

- 也可以反向关闭::

   dnf config-manager --set-disabled repository…

参考 `Adding, Enabling, and Disabling a DNF Repository <https://docs.fedoraproject.org/en-US/Fedora/23/html/System_Administrators_Guide/sec-Managing_DNF_Repositories.html>`_

- 列出所有RPM包::

   dnf list

- 列出所哟安装了RPM包::

   dnf list installed

- 列出所有可供安装的RPM包（包括了所有可用软件库的可供安装的软件包）::

   dnf list available

- 搜索软件库中的软件包::

   dnf search syslog-ng

- 查找某个文件的提供者::

   dnf provides /bin/bash

- 查看软件包的详情::

   dnf info bash

- 升级软件包::

   dnf update systmed

- 检查软件包的更新 - 检查系统中所有软件包的更新::

   dnf check-update

- 升级系统中所有可以升级的软件包::

   dnf update
   # 或
   dnf upgrade

- 删除软件包::

   dnf remove nano

- 删除无用软件包：当没有软件再依赖时，某些用于解决特定软件依赖的软件包可以清理掉::

   dnf autoremove

- 删除缓存的无用软件包::

   dnf clean all

- 获取某条命令的使用帮助::

   dnf help clean

- 查看所有的DNF命令及用途::

   dnf help

- 查看DNF命令的执行历史::

   dnf history

- 查看所有的软件包组::

   dnf grouplist

- 安装一个软件包组::

   dnf groupinstall 'Educational Software'

- 升级一个软件包组中的软件包::

   dnf groupupdate 'Educational Software'

- 删除一个软件包组::

   dnf groupremove 'EDucational Software'

- 从特定的软件包安装特定的软件::

   dnf --enablerepo=epel install phpmyadmin

- 更新软件包都最新的稳定发行版：这个命令可以通过所有可用的软件源更新系统中所有已经安装的软件包到最新的稳定版本::

   dnf distro-sync

- 重装特定软件包::

   def reinstall nano

- 回滚某个特定的软件版本::

   dnf downgrade acpid

yum 和 dnf 命令差异
====================

- 在 DNF 中没有 ``--skip-broken`` 命令，并且没有替代命令供选择
- 在 DNF 中没有判断哪个包提供了指定依赖的 ``resolvedep`` 命令
- 在 DNF 中没有用来列出某个软件依赖包的 deplist 命令。
- 当你在 DNF 中排除了某个软件库，那么该操作将会影响到你之后所有的操作，不像在 YUM 下那样，你的排除操作只会在升级和安装软件时才起作用。

DNF插件和高级命令
==================

DNF通过一些插件提供了安装debuginfo包或下载仓库中RPM的功能

======================  ============================== ================================
YUM command             DNF command                    提供的软件包
======================  ============================== ================================
debuginfo-install       dnf debuginfo-install          dnf-plugins-core
repoquery               dnf repoquery                  dnf-plugins-core
yum-builddep            dnf builddep                   dnf-plugins-core
yum-config-manager      dnf config-manager             dnf-plugins-core
yumdownloader           dnf download                   dnf-plugins-core
repo-graph              dnf repograph                  dnf-plugins-extras-repograph
======================  ============================== ================================

参考
========

- `DNF的命令使用教学 <https://linuxstory.org/dnf-commands-for-fedora-rpm-package-management/>`_
- `Fedora的包管理器已从Yum切换到DNF <http://www.lupaworld.com/article-252512-1.html>`_
- `Managing packages on Fedora with DNF <https://fedoramagazine.org/managing-packages-fedora-dnf/>`_
- `Yum is dead, long live DNF <http://dnf.baseurl.org/2015/05/11/yum-is-dead-long-live-dnf/>`_
- `DNF Fedora文档 <https://fedoraproject.org/wiki/DNF?rd=Dnf>`_

