.. _init_centos:

=====================
CentOS系统管理初始化
=====================

- 激活常用的软件仓库 PowerTools 和 EPEL::

   dnf install epel-release
   dnf install dnf-plugins-core
   dnf config-manager --set-enabled PowerTools

CentOS 8最小化server模式安装，对于开发环境初始化安装软件包::

   dnf install nmon which sudo nmap-ncat mlocate net-tools rsyslog file \
   wget tar bzip2 screen sysstat unzip nfs-utils parted lsof man bind-utils \
   gcc gcc-c++ make telnet flex autoconf automake ncurses-devel crontabs \
   zlib-devel git

如果编译LFS，则:

.. literalinclude:: ../../lfs/lfs_prepare/dnf_install_env
   :caption: 在Fedora环境安装LFS编译环境

.. note::

   如果要全面开发，也可以简单安装 ``dnf group install "Development Tools"`` ，但是这个安装方式将占据600+M

CentOS 8标准server模式安装，对于开发环境初始化安装软件包::

   dnf install sysstat nfs-utils gcc gcc-c++ make \
   telnet flex autoconf automake ncurses-devel zlib-devel git

对于编译软件包需要同时生成man手册，还需要安装 pandoc (markup格式转换工具，可以转换epub, docx, markdown, reStructuredText等等) ，可参考 `How to install pandoc on CentOS <http://tutorialspots.com/how-to-install-pandoc-on-centos-4902.html>`_ 安装。 
