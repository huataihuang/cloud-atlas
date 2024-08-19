.. _apt:

==========
APT包管理
==========

contrib/non-free软件包
=========================

有些厂商提供的软件包是存放在"捐献"(contrib)和"非自由"(non-free)范畴的，默认没有激活。例如，在NVIDIA CUDA提供了PyCUDA ( :ref:`jetson_pycuda` ) 就属于 contrib area 。

- 编辑 ``/etc/apt/sources.lst`` ，将 ``contrib`` 和 ``non-free`` 的配置行激活就可以使用 contrib 和 non-free 仓库::

   deb http://deb.debian.org/debian buster main contrib non-free
   deb-src http://deb.debian.org/debian buster main contrib non-free

APT代理
========

HTTP
------

在墙内很多软件仓库由于GFW屏蔽，导致系统部署存在很大障碍。主要的解决方法是构建 :ref:`linux_vpn` 结合 :ref:`squid` 代理来翻墙，例如我在部署CentOS/SUSE的系统就采用 :ref:`polipo_proxy_yum` 。

Ubuntu/Debian使用的APT软件包管理也支持代理配置，这里我结合 :ref:`squid_socks_peer` 实现完美翻墙代理。

在Ubuntu上安装软件时，如果需要使用代理服务器，可以在 ``/etc/apt/apt.conf`` 中设置，添加如下行::

   Acquire::http::Proxy "http://yourproxyaddress:proxyport";

如果代理服务器需要密码和账号登陆，则将::

   "http://yourproxyaddress:proxyport";

修改成::

   "http://username:password@yourproxyaddress:proxyport";

上述翻墙方式采用本地运行 :ref:`squid` 代理服务器，所以APT代理设置是 ``http`` 协议，采用如下配置::

   Acquire::http::Proxy "http://192.168.6.200:3128/";

SOCKS
---------

如果是临时或者简化配置，本地不部署 :ref:`squid` 代理也可以，只要简单使用 :ref:`ssh_tunneling` ::

   ssh -D 10080 -C huatai@<remote_server>

然后配置本地APT使用代理 ``/etc/apt/apt.conf.d/proxy.conf`` ::

   Acquire::http::Proxy "socks5h://127.0.0.1:10080";
   Acquire::https::Proxy "socks5h://127.0.0.1:10080";
   Acquire::socks::Proxy "socks5h://127.0.0.1:10080";

proxy.conf
============

现在比较新的Ubuntu版本，有关apt的配置都存放在 ``/etc/apt/apt.conf.d`` 目录下，所以建议将代理配置设置为 ``/etc/apt/apt.conf.d/proxy.conf`` ::

   Acquire::http::Proxy "http://user:password@proxy.server:port/";
   Acquire::https::Proxy "http://user:password@proxy.server:port/";

.. _apt-file:

文件查找
=========

我们经常需要找到某个程序文件属于哪个软件包，例如需要安装或者卸载某个文件。

- 对于已经安装的软件包，可以通过 ``dpkg`` 工具查找::

   dpkg -S /bin/ls

这个命令有点类似 :ref:`redhat_linux` 中的 ``rpm -q /bin/ls``

- 对于尚未安装的软件包，我们需要搜索软件仓库，则建议安装 ``apt-file`` 工具来搜索::

   sudo apt install apt-file
   sudo apt-file update
   apt-file find kwallet.h

此外，你可以可以通过 `Ubuntu Packages Search <http://packages.ubuntu.com/>`_ 网站来查找软件包。

``apt-add-repository``
============================

第三方软件仓库也称为  ``Launchpad PPA (Personal Package Archive)`` 

第三方软件仓库需要使用 ``apt-add-repository`` 命令添加，不过这个工具命令默认没有安装，所以首先执行::

   sudo apt install software-properties-common
   sudo apt update

然后可以使用以下命令添加PPA::

   sudo add-apt-repository ppa:apandada1/foliate

然后更新仓库:

.. literalinclude:: apt/apt_update
   :caption: apt更新系统

此时可能报错::

   ...
   Get:5 http://ppa.launchpad.net/apandada1/foliate/ubuntu kinetic InRelease [17.5 kB]
   Err:5 http://ppa.launchpad.net/apandada1/foliate/ubuntu kinetic InRelease
     The following signatures couldn't be verified because the public key is not available: NO_PUBKEY A507B2BBA7803E3B
   Reading package lists... Done
   W: GPG error: http://ppa.launchpad.net/apandada1/foliate/ubuntu kinetic InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY A507B2BBA7803E3B
   E: The repository 'http://ppa.launchpad.net/apandada1/foliate/ubuntu kinetic InRelease' is not signed.
   N: Updating from such a repository can't be done securely, and is therefore disabled by default.
   N: See apt-secure(8) manpage for repository creation and user configuration details.

则执行以下命令::

   sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A507B2BBA7803E3B

第三方 :ref:`grafana` 仓库
----------------------------

在安装 :ref:`grafana` 以及升级过程中，也遇到(Grafana)服务器证书更换的问题，此时无法升级软件，报错也类似如上(不过这次这个证书是Grafana提供的，非Ubuntu):

.. literalinclude:: apt/grafana_pub_key_error
   :caption: ``apt`` 更新时遇到Grafana网站证书更新报错
   :emphasize-lines: 1

.. note::

   这里除了 Grafana Pub Key 错误之外，另外几行报错是 :ref:`install_pcp` 之前的方法因为JForg免费仓库关闭服务导致，后续再更新 :ref:`install_pcp` 方法

这个问题的解决方法类似，执行一下命令更新服务器存储的Grafana证书(方法参见 `Welcome to Grafana Labs's package repository <https://packages.grafana.com/>`_ ):

.. literalinclude:: apt/update_grafana_pub_key
   :caption: ``apt`` 更新Grafana网站证书

.. _apt_hold:

apt hold保持包不更新
========================

我在 :ref:`kubeadm_upgrade_k8s_fail_record` 之后才发现在 :ref:`k8s_deploy` 步骤中有一个不起眼的操作 ``apt hold`` 是非常重要的: 确保操作系统升级时不自动升级 :ref:`kubernetes` 相关软件包。这是因为Kubernetes升级版本需要遵循一定的规则和顺序，直接升级有可能导致数据错乱。

使用 ``apt-mark`` 工具可以保持软件包不被系统自动升级，也可以使用这个工具来检查 ``hold`` 住的软件包:

- 完成 :ref:`k8s_deploy` 之后，锁定 :ref:`kubernetes` 相关软件不升级::

   apt-mark hold kubelet kubeadm kubectl

- 检查当前 ``hold`` 住的软件包::

   apt-mark showhold

- 解锁 ``hold`` 住的软件包::

   apt-mark unhold kubelet kubeadm kubectl

apt源代码安装和编译
=====================

我在 :ref:`build_lineageos_20_pixel_4` 遇到一个需要编译 ``git with openssl`` 来解决通过 :ref:`squid_socks_peer` 使用 :ref:`git_proxy` 的问题。这个案例采用了ubuntu发行版提供的软件包源代码编译安装，步骤是可借鉴的:

- 安装编译环境:

.. literalinclude:: ../../../devops/git/git-openssl/gt_build_dependencies
   :caption: 安装git编译依赖环境

- 修改 ``/etc/apt/sources.list`` 将源代码仓库激活(默认没有激活或配置):

.. literalinclude:: ../../../devops/git/git-openssl/sources.list
   :caption: 配置apt源代码源
   :emphasize-lines: 2,4,6

- 更新仓库索引然后安装 ``git`` 源代码:

.. literalinclude:: ../../../devops/git/git-openssl/apt_source_git
   :caption: 更新仓库索引然后安装 ``git`` 源代码

- 安装 ``libcurl`` :

.. literalinclude:: ../../../devops/git/git-openssl/apt_libcurl
   :caption: 安装 libcurl

- 进入git源代码目录，修改2个文件，然后重新编译git:

.. literalinclude:: ../../../devops/git/git-openssl/recompile_git_with_openssl
   :caption: 修订配置后重新编译git with openssl

- 然后进入上级目录安装编译后的deb包:

.. literalinclude:: ../../../devops/git/git-openssl/pkg_install_git_with_openssl
   :caption: 安装编译后的deb包

参考
========

- `Configure proxy for APT? <https://askubuntu.com/questions/257290/configure-proxy-for-apt>`_
- `How do I find the package that provides a file? <https://askubuntu.com/questions/481/how-do-i-find-the-package-that-provides-a-file>`_
- `How to Fix 'add-apt-repository command not found' on Ubuntu & Debian <https://phoenixnap.com/kb/add-apt-repository-command-not-found-ubuntu>`_
- `apt-get hold back packages on Ubuntu / Debian Linux <https://www.cyberciti.biz/faq/apt-get-hold-back-packages-command/>`_ 有多种hold软件包的方法，不过常用的 ``apt-mark`` 已经足够
