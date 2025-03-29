.. _suse_iso_repo:

================================
使用SUSE的DVD iso构建安装仓库
================================

在SUSE安装完成后，我们有可能还需要使用DVD来安装一些必要软件。比较灵活的方法是将镜像文件作为安装仓库，这样以后就不再需要反复使用安装光盘了。

- 如果需要从安装光盘制作ISO文件，可以使用以下命令::

   mkisofs -iso-level 4 -J -R -o /home/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso /media/SU1100.001/

- 将ISO添加到仓库::

   zypper ar -c -t yast2 "iso:/?iso=/home/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso" "SLES 12 SP3"

- 检查仓库::

   zypper repos

输出显示::

   Repository priorities are without effect. All enabled repositories share the same priority.
   
   # | Alias             | Name              | Enabled | GPG Check | Refresh
   --+-------------------+-------------------+---------+-----------+--------
   1 | SLES 12 SP3       | SLES 12 SP3       | Yes     | ( p) Yes  | No     
   2 | SLES12-SP3-12.3-0 | SLES12-SP3-12.3-0 | No      | ----      | ----

- 如果要删除仓库::

   zypper rr 1

- (可选)激活自动刷新::

   zypper mr -r "SLES 12 SP3"

- 现在我们可以安装软件了::

   zypper in -y nmap

参考
======

- `Create an ISO from your openSUSE DVD and add it as an installation source from the command line <https://www.suse.com/c/create-iso-your-opensuse-dvd-and-add-it-installation-source-command-line/>`_
