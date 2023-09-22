.. _build_glusterfs_11_for_centos_7:

==============================
CentOS 7环境编译GlusterFS 11
==============================

.. note::

   本文实践在CentOS 7上完成，其他平台编译方法摘录原文以备参考 :ref:`build_install_glusterfs`

准备工作
===========

我走的弯路(实际不需要)
-----------------------

- **不要** :strike:`激活EPEL 以便安装` :

.. literalinclude:: ../../linux/redhat_linux/admin/dnf/yum_install_epel-release
   :language: bash
   :caption: yum命令安装EPEL仓库 release(实践发现不应该激活)

- **不要** 激活 :ref:`openstack_env_repo` 以便能够安装 ``python-paste-deploy`` / ``python-eventlet`` / ``python2-simplejson`` :

.. literalinclude:: ../../openstack/installation/environment/openstack_env_repo/centos7_train
   :language: bash
   :caption: CentOS 7安装激活OpenStack Train版本软件仓库

.. warning::

   这里我走了弯路，因为官方原文中安装依赖有4个软件包在CentOS 7中找不到，我通过rpm搜索找到了提供软件包的仓库( ``EPEL`` 和 ``OpenStack`` )，但是实际上这会引入高版本Python 3.6以及 ``mock`` (基于Python 3.6)，反而导致 ``make glusterrpm`` 失败。见下文

   原文中有以下4个软件包在CentOS7中不存在::

      cmockery2-devel
      python-eventlet
      python-paste-deploy
      python-simplejson

   原因是是:

   - ``cmockery2-devel`` 需要激活EPEL(不过我在 :ref:`build_glusterfs_11_for_centos_7` 遇到 ``make glusterrpms`` 报错，参考 `Compilation failed on glusterfs master branch(python2.7 (default) and python3.6) <https://github.com/gluster/glusterfs/issues/799>`_ 不应该使用EPEL避免引入python 3以及python 3版本的 ``mock`` 否则无法构建GlusterFS rpm:

   .. literalinclude:: build_glusterfs_11_for_centos_7/make_glusterrpms_python2
      :caption: RHEL7和CentOS7是"python2"，避免引入Python3影响GlusterFS编译RPM

   - ``python-paste-deploy`` / ``python-eventlet``  是 :ref:`openstack` 仓库提供，不使用OpenStack可能可以忽略，不过我参考 `phone.net <http://rpm.pbone.net/>`_ 搜索对应于不同 :ref:`centos` 的 :ref:`openstack` 版本，例如对于 CentOS 7.9.2009 有多个版本，即 ``rocky`` , ``train`` , ``queens`` , ``stein`` ，激活仓库
   - ``python-simplejson`` 改名成 ``python2-simplejson`` 也是 :ref:`openstack` 仓库提供

   **经过实践， CentOS 7应该不要安装这4个软件包** 可以避免引入 Python 3.6 (EPEL)

实际需要的步骤
----------------

- 需要先激活 :ref:`centos_sig_gluster` 以便能够安装 ``userspace-rcu-devel`` :

.. literalinclude:: ../deploy/centos_sig_gluster/install_centos_storage_sig
   :caption: 安装CentOS Storage SIG Yum Repos

.. note::

   如果你的CentOS(例如aliOS)没有提供上述 ``centos-release-gluster`` ，并且发行版也没有提供 ``userspace-rcu-devel`` ，则可以尝试直接从 `CentOS 7.9.2009 storage u <http://mirror.centos.org/centos-7/7.9.2009/storage/x86_64/gluster-9/Packages/u/>`_ 直接下载安装 ``userspace-rcu-devel`` :

   .. literalinclude:: build_glusterfs_11_for_centos_7/install_userspace-rcu-devel
      :caption: 直接安装社区提供 ``userspace-rcu-devel``

- 使用 yum 在CentOS / Enterprise Linux 7上安装编译环境:

.. literalinclude:: build_install_glusterfs/build_requirements_for_centos7
   :language: bash
   :caption: RHEL/CentOS7环境编译GlusterFS安装的编译工具软件包

.. note::

   CentOS 7.2没有提供 ``python-netifaces`` (在CentOS 7.9则有)

下载
========

- `GlusterFS官方下载 <https://download.gluster.org/pub/gluster/glusterfs>`_ 源代码包 ``glusterfs-11.0`` :

.. literalinclude:: build_install_glusterfs/download_glusterfs_11_tgz
   :caption: 下载 ``glusterfs-11.0`` 源代码tgz包

配置编译
===========

- 使用 ``autogen`` 生成 ``configure`` 脚本:

.. literalinclude:: build_install_glusterfs/autogen_glusterfs
   :caption: 使用 ``autogen`` 生成GusterFS的 ``configure`` 脚本

- 针对CentOS 7使用以下编译配置:

.. literalinclude:: build_install_glusterfs/configure_glusterfs_for_centos7
   :caption: 执行 ``configure`` 脚本(注意关闭CentOS 7不支持选项)

编译配置显示如下:

.. literalinclude:: build_install_glusterfs/configure_glusterfs_for_centos7_output
   :caption: 执行 ``configure`` 脚本(注意关闭CentOS 7不支持选项)输出

配置报错及处理
-----------------

- ``tcmalloc`` 库错误::

   configure: error: tcmalloc library needs to be present

参考 `Install tcmalloc on CentOS <https://stackoverflow.com/questions/52103646/install-tcmalloc-on-centos>`_ 安装 ``gperftools`` 相关包::

   yum install gperftools gperftools-devel

- ``io_uring`` 错误::

   configure: error: Install liburing library and headers or use --disable-linux-io_uring

``io_uring`` 是Linux内核5.1引入的特性，GlusterFS需要使用用户空间 ``liburing helper`` 库，对于不支持的主机，使用 ``--disable-linux-io_uring`` 关闭这个支持选项

编译和安装
============

- 编译和安装GlusterFS非常简单:

.. literalinclude:: build_install_glusterfs/glusterfs_make_install
   :caption: 执行编译和安装

编译RPMs
============

在基于 RPM 的系统中，如 :ref:`fedora` 可以非常容易直接构建RPM包

- 在 :ref:`fedora` / :ref:`centos` / RHEL 系统中安装依赖:

.. literalinclude:: build_install_glusterfs/install_rpm-build
   :caption: 安装 ``rpm-build`` 构建工具

.. note::

   CentOS 7.2 没有提供 ``mock`` 不过不影响编译RPM包

- 然后执行以下命令构建GlusterFS RPMs:

.. literalinclude:: build_install_glusterfs/glusterrpms_centos7
   :caption: 执行构建GlusterFS RPMs

构建GlusterFS RPMs输出信息显示，实际上构建参数增加了一个 ``--enable-gnfs`` ，其余参数就是之前我编译GlusterFS参数:

.. literalinclude:: build_install_glusterfs/glusterrpms_output
   :caption: 执行构建GlusterFS RPMs

编译RPMs错误处理
------------------

- 缺少 ``pkgconfig`` 依赖::

   ...
   rpmbuild --define '_topdir /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild' -bs rpmbuild/SPECS/glusterfs.spec
   Wrote: /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild/SRPMS/glusterfs-11.0-0.0.el7.src.rpm
   mv rpmbuild/SRPMS/* .
   rpmbuild --define '_topdir /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild' --with gnfs -bb rpmbuild/SPECS/glusterfs.spec
   error: Failed build dependencies:
           pkgconfig(bash-completion) is needed by glusterfs-11.0-0.0.el7.x86_64
   make: *** [rpms] Error 1

但是，很奇怪，系统已经安装过 ``pkgconfig`` : ``pkgconfig-0.27.1-4.el7.x86_64 already installed and latest version``

``rpmbuild/SPECS/glusterfs.spec`` 中有如下配置::

   %global bashcompdir %(pkg-config --variable=completionsdir bash-completion 2>/dev/null)
   %if "%{bashcompdir}" == ""
   %global bashcompdir ${sysconfdir}/bash_completion.d
   %endif

这里如果手工执行 ``pkg-config --variable=completionsdir bash-completion`` 是没有任何输出信息

我Google了一下，原来系统有提供一个独立的 ``bash-completion`` - `RPM resource pkgconfig(bash-completion) <https://rpmfind.net/linux/rpm2html/search.php?query=pkgconfig(bash-completion)>`_ ，安装这个软件包::

   yum install bash-completion

然后手工执行 ``pkg-config --variable=completionsdir bash-completion`` 就有输出信息了::

   /usr/share/bash-completion/completions

然后就能够重新开始 ``make glusterrpms``

- 缺少 ``python2-gluster`` 文件错误::

   ...
   Processing files: python2-gluster-11.0-0.0.el7.x86_64
   error: Directory not found: /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-11.0-0.0.el7.x86_64/usr/lib/python2.7/site-packages/gluster
   error: File not found by glob: /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-11.0-0.0.el7.x86_64/usr/lib/python2.7/site-packages/gluster/__init__.*
   error: File not found: /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-11.0-0.0.el7.x86_64/usr/lib/python2.7/site-packages/gluster/cliutils
   
   
   RPM build errors:
       Directory not found: /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-11.0-0.0.el7.x86_64/usr/lib/python2.7/site-packages/gluster
       File not found by glob: /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-11.0-0.0.el7.x86_64/usr/lib/python2.7/site-packages/gluster/__init__.*
       File not found: /home/huatai/glusterfs-11.0/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-11.0-0.0.el7.x86_64/usr/lib/python2.7/site-packages/gluster/cliutils
   make: *** [rpms] Error 1

我检查了我之前直接 ``make`` 安装的 ``make install`` ，在主机系统中也没有 ``/usr/lib/python2.7/site-packages/gluster`` ，这说明之前编译也没有支持python。奇怪，从 ``configure`` 输出显示是有 ``With Python  : 2.7``

参考 `Bug 1510685 - Python modules not found when multiple versions of Python installed <https://bugzilla.redhat.com/show_bug.cgi?id=1510685>`_ 可以通过如下命令检查系统 python 的 ::

   python2 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"

输出显示::

   /usr/lib/python2.7/site-packages

参考 `Compilation failed on glusterfs master branch(python2.7 (default) and python3.6) <https://github.com/gluster/glusterfs/issues/799>`_ ，对于CentOS 7这样同时安装了Python 2.7(默认)以及Python 3.6的系统，需要在执行 ``make glusterrpms`` 前先指定 ``PYTHON`` ::

   PYTHON=/usr/bin/python2.7 make glusterrpms

不过并没有解决我的问题。在这个issue中我看到一个提示:

.. literalinclude:: build_glusterfs_11_for_centos_7/make_glusterrpms_python2
   :caption: RHEL7和CentOS7是"python2"，避免引入Python3影响GlusterFS编译RPM

也就是说，我在 :ref:`build_install_glusterfs` 为了安装 ``cmockery2-devel`` 激活了 ``EPEL`` 画蛇添足导致了问题。尝试卸载 ``python36`` ， **明白了** ::

   Dependencies Resolved

   ====================================================================================
    Package                            Arch       Version          Repository     Size
   ====================================================================================
   Removing:
    python3                            x86_64     3.6.8-18.el7     @updates       39 k
   Removing for dependencies:
    mock                               noarch     2.17-1.el7       @epel         814 k
    mock-core-configs                  noarch     36.17-1.el7      @epel         313 k
    python3-libs                       x86_64     3.6.8-18.el7     @updates       35 M
    python3-pip                        noarch     9.0.3-8.el7      @base         9.1 M
    python3-setuptools                 noarch     39.2.0-10.el7    @base         3.6 M
    python3-templated-dictionary       noarch     1.1-1.el7        @epel          29 k
    python36-chardet                   noarch     3.0.4-1.el7      @epel         1.4 M
    python36-distro                    noarch     1.5.0-1.el7      @epel         154 k
    python36-idna                      noarch     2.10-1.el7       @epel         850 k
    python36-jinja2                    noarch     2.11.1-1.el7     @epel         1.2 M
    python36-markupsafe                x86_64     0.23-3.el7       @epel         100 k
    python36-pyroute2                  noarch     0.4.13-2.el7     @epel         1.8 M
    python36-pysocks                   noarch     1.6.8-7.el7      @epel         101 k
    python36-requests                  noarch     2.14.2-2.el7     @epel         533 k
    python36-rpm                       x86_64     4.11.3-10.el7    @epel         905 k
    python36-six                       noarch     1.14.0-3.el7     @epel         138 k
    python36-urllib3                   noarch     1.25.6-2.el7     @epel         865   

原来激活了 ``EPEL`` 后，会导致安装 ``mock`` 工具时，由于 ``EPEL`` 提供了更高版本的基于 ``python36`` 的版本，导致没有安装CentOS 7发行版提供的针对 ``python2.7`` 的低版本 ``mock``

解决方法是移除 ``python36`` (会关联卸载 ``EPEL`` 版本的 ``mock`` )，关闭 EPEL ，然后重新安装 ``mock`` (此时会安装CentOS 7发行版的 ``mock`` ):

.. literalinclude:: build_glusterfs_11_for_centos_7/remove_python36_disable_epel
   :caption: 移除Python 3.6并关闭EPEL
   
参考
======

- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
- `Compiling RPMS <https://docs.gluster.org/en/latest/Developer-guide/compiling-rpms/#common-steps>`_
