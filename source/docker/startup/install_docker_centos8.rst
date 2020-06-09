.. _install_docker_centos8:

==========================
在CentOS 8上安装Docker CE
==========================

在 :ref:`gvisor_quickstart` 中，我在CentOS 8系统中构建gVisor编译安装环境，其中使用了Docker CE安装部署，本文作为通用安装指南，汇总CentOS 8操作系统安装Docker CE的步骤。

添加Docker CE仓库
===================

当前CentOS发行版和EPEL都没有提供gVisor安装包，需要从源代码编译。运行gVisor需安装docker。

* docker仓库::

   # 添加docker-ce仓库
   sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

   # 检查所有仓库列表
   sudo dnf repolist -v
   # 将所有docker-ce版本列出
   dnf list docker-ce --showduplicates | sort -r

.. note::

   安装列表中显示docker-ce是为el7编译的

安装docker-ce
==============

安装docker-ce有两种模式，一种是直接使用仓库中最佳可用版本，使用参数 ``--nobest`` 则安装的是stable版本 ；另一种是使用最新的可用版本，则不需要参数，但是这种安装模式需要最新的contained(没有包含在软件仓库)。

* 方法一：最简洁方便的安装方式，安装稳定版本::

   sudo dnf install --nobest docker-ce

* 方法二：安装最新可用版本

安装最新可用版本需要先安装必要的containerd.io，不过有多个containerd.io版本，执行 ``dnf install docker-ce`` 时会提示::

   Error:
    Problem: package docker-ce-3:19.03.8-3.el7.x86_64 requires containerd.io >= 1.2.2-3, but none of the providers can be installed
    - cannot install the best candidate for the job
    - package containerd.io-1.2.10-3.2.el7.x86_64 is excluded
    - package containerd.io-1.2.13-3.1.el7.x86_64 is excluded
    ...

所以先安装containerd.io::

   sudo dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.2.el7.x86_64.rpm

然后执行安装docker-ce::

   sudo dnf install docker-ce

.. note::

   我当前在 :ref:`docker_in_docker` 环境部署持续集成系统，采用的是最新版本，即方法2。

* 关闭firewalld::

   sudo systemctl disable firewalld

* 启动和激活docker服务::

   sudo systemctl enable --now docker

安装docker-compose(可选)
=========================

docker-compose可以帮助管理多容器应用，类似 :ref:`kubernetes_workloads_pods` ，组合多个容器形成应用服务架构。不过，需要独立手工安装::

   curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o docker-compose
   sudo mv docker-compose /usr/local/bin && sudo chmod +x /usr/local/bin/docker-compose

参考
======

- `How to Install Docker CE on CentOS 8 / RHEL 8 <https://www.linuxtechi.com/install-docker-ce-centos-8-rhel-8/>`_
