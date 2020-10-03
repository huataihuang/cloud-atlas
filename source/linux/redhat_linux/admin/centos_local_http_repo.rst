.. _centos_local_http_repo:

======================
CentOS本地HTTP软件仓库
======================

当一次次通过Internet安装和更新CentOS，当运维当服务器越来越多，你一定会有一个强烈的愿望，构建一个本地CentOS软件仓库。这样只要同步一次集中的软件仓库，就可以提供本地局域网所有CentOS服务器更新到相同版本。

.. note::

   强烈推荐使用 ``reposync`` 工具进行软件仓库同步，这个工具是通用工具，不仅适合CentOS发行版的软件仓库，也可以用于其他符合Red Hat YUM仓库规范的软件仓库同步。例如，我也使用这个工具来同步Docker CE和Kubernetes仓库，可以提供给本地局域网服务器公用安装。

   如果要同步不同软件版本，例如，要同步CentOS 7/6/5或者不同架构。我觉得可以采用Docker方式来运行专用同步客户端，甚至可以采用 :ref:`kubernetes` 运行 :ref:`daemonset` 来完成。后续我可能会再部署一整套同步方案，来适用于不同Red Hat发行版，Ubuntu发行版，SUSE发行版以及ARM架构的Fedora/Ubuntu同步。构建一个完整的仓库镜像方案。

CentOS 8包含2个仓库: ``BaseOS`` 和 ``AppStream`` (Application Stream):

- BaseOS是最小化操作系统所需要的软件包
- AppStream则包含其余软件包，依赖和数据库

安装HTTP服务(Nginx)
=====================

- 安装Nginx软件包::

   dnf install epel-release
   dnf install nginx

- 配置nginx允许index浏览(非必须，仅为了方便查看)::

   xxx 

- 启动Nginx::

   systemctl start nginx
   systemctl enable nginx

- 打开对外80端口和443端口允许外部访问Nginx服务，更新防火墙规则如下::

   firewall-cmd --zone=public --permanent --add-service=http
   firewall-cmd --zone=public --permanent --add-service=https
   firewall-cmd --reload

- 现在在浏览器中通过 http://<SERVER_DOMAIN_NAME_OR_IP> 能够正常访问Nginx的初始页面，就证明WEB服务器已经构建好。

镜像ISO文件创建仓库
=====================

- 如果你手边有安装光盘ISO文件，则采用以下方法挂载ISO文件::

   mount -ro loop CentOS-8.2.2004-x86_64-dvd1.iso /mnt

- 创建centos8的iso_repo目录::

   mkdir -p /var/www/html/centos/8.2.2004/iso_repo/x86_64
   ln -s /var/www/html/centos/8.2.2004 /var/www/html/centos/8

- 将ISO镜像文件复制到WEB目录下::

   (cd /mnt && tar cvf -.) | (cd /var/www/html/centos/8/iso_repo/x86_64 && tar xvf -)

如果你不使用tar命令，也可以使用rsync命令::

   rsync -avHPS /mnt/ /var/www/html/centos/8/iso_repo/x86_64/

.. note::

   ``iso_repo/x86_64`` 应该和仓库镜像网站的 ``BaseOS/x86_64/os/`` 目录内容相同，如果你使用镜像网站同步，本步骤可以忽略。

同步repo
==========

DNF提供了 ``reposync`` 插件，这个插件在以前yum时候包含在 ``yum-utils`` 中，现在也是可以通过 ``yum-utils`` 获得::

   dnf install yum-utils createrepo

.. note::

   yum-utils 包含了 ``reopsync`` 工具，而 createrepo 提供了在本地目录构建仓库索引功能。

执行 ``dnf reposync [options]`` 可以将Internet上的软件仓库镜像到本地。

CentOS 8仓库
============

- 在本地创建对应目录::

   mkdir -p /usr/share/nginx/html/centos/8/{BaseOS,AppStream,extras}/x86_64/os/

.. note::

   之所以我选择创建这样的子目录 ``centos/8/{BaseOS,AppStream,extras}/x86_64/os/`` 是因为我参考 http://mirrors.163.com 来构建目录以区分不同架构。

   实际 ``reposync`` 下载会在指定目录下创建 ``Packages`` 和 ``repodata`` 子目录，这样可以和 mirrors.163.com 相仿。

- 同步激活的repo仓库和其包含的repodata::

   dnf reposync -p /usr/share/nginx/html/centos/8/BaseOS/x86_64/os/ -a x86_64 -n --delete --norepopath --download-metadata --repoid=BaseOS
   dnf reposync -p /usr/share/nginx/html/centos/8/AppStream/x86_64/os/ -a x86_64 -n --delete --norepopath --download-metadata --repoid=AppStream
   dnf reposync -p /usr/share/nginx/html/centos/8/extras/x86_64/os/ -a x86_64 -n --delete --norepopath --download-metadata --repoid=extras

.. note::

   - ``-p <download-path>, --download-path=<download-path>`` 指定下载目录，如果没有提供参数就会下载到当前目录。每个下载仓库都会在这个目录下有一个自己ID的子目录
   - ``-a <architecture>, --arch=<architecture>`` 下载指定架构的软件包(默认是下载所有架构)。这个参数可以同时使用多次以便指定多个架构。 **注意** 即使是 ``x86_64`` 架构的软件仓库，也有很多软件包是 ``noarch`` 的，所以必须同时使用 ``-a x86_64 -a noarch`` 。不过，我觉得可能不需要指定 ``-a`` 参数，实际上软件仓库下载都是按照同步服务器的所需软件包来下载的。
   - ``-n, --newest-only`` 只下载每个仓库中最新的软件包
   - ``--delete`` 删除不在仓库中的本地软件包
   - ``--norepopath`` 不在下载目录下添加repo名字，例如再添加一个 ``BaseOS`` **不过这个参数需要 dnf-plugins-core-4.0.14 以上版本才支持** ( `dnf-plugins-core release notes <https://dnf-plugins-core.readthedocs.io/_/downloads/en/latest/pdf/>`_ )之前的reposync会强制在同步目录下创建一个 ``repoid`` 子目录，实际上就会和默认的repo目录不一致。
   - ``--download-metadata`` 下载所有repository meatadata，这样就不需要再使用 ``createrepo`` 命令再创建metadata

.. note::

   ``repoid`` 可以通过 ``dnf replist`` 看到，例如用来同步的服务器，请使用 ``dnf replist`` 检查需要的仓库列表，选择必要同步的仓库同步。详细请参考 :ref:`dnf`

- 为了能够方便进行多个repo同步，实际我采用以下脚本 ``reposync.sh``

.. literalinclude:: yum.repos.d/reposync_sh
    :language: bash
    :linenos:
    :caption:

客户端repo配置
================

客户端的配置是修订发行版软件仓库配置来实现的，基本方式就是注释掉 ``mirrorlist=`` 配置，然后启用 ``baseurl=`` 配置，但是采用本地局域网提供软件仓库的服务器IP地址或者内部域名。举例：

.. literalinclude:: yum.repos.d/CentOS-Base.repo
    :language: bash
    :linenos:
    :caption:

.. note::

   安装软件需要GPG密钥，请单独从官方服务器下载，存放到内网软件仓库下载服务器上提供下载。

我为了方便分发客户端配置，采用了脚本:

.. literalinclude:: yum.repos.d/replace_repo_file
    :language: bash
    :linenos:
    :caption:

参考
====

- `How to create a local mirror of the latest update for Red Hat Enterprise Linux 5, 6, 7, 8 without using Satellite server? <https://access.redhat.com/solutions/23016>`_
- `Configure DNF/Yum Mirror Server <https://www.server-world.info/en/note?os=CentOS_8&p=localrepo>`_
- `How to Set Up a Local Yum/DNF Repository on CentOS 8 <https://www.tecmint.com/create-local-yum-repository-on-centos-8/>`_
- `DNF reposync Plugin <https://dnf-plugins-core.readthedocs.io/en/latest/reposync.html>`_
- `How to Setup Local HTTP Yum Repository on CentOS 7 <https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/>`_
- `Creating Local Mirrors for Updates or Installs <https://wiki.centos.org/HowTos/CreateLocalMirror>`_
- `How To Set Up Local Yum Repositories On CentOS 7 <https://phoenixnap.com/kb/create-local-yum-repository-centos>`_
