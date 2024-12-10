.. _wget:

========
wget
========

wget是常用下载工具

``wget`` 指定下载目录
=======================

- wget下载文件到指定目录 ``-P prefix`` ::

   -P prefix
   --directory-prefix=prefix
              Set directory prefix to prefix.  The directory prefix is the
              directory where all other files and sub-directories will be
              saved to, i.e. the top of the retrieval tree.  The default
              is . (the current directory).

举例::

   wget <file.ext> -P /path/to/folder

``wget`` 指定下载后文件名
==========================

- wget下载文件到指定目录下文件名 ``-O filename`` ::

   -O file
   --output-document=file
       The documents will not be written to the appropriate files, but all will be
       concatenated together and written to file.  If - is used as file, documents will be
       printed to standard output, disabling link conversion.  (Use ./- to print to a file
       literally named -.)

举例::

   wget <file.ext> -O /path/to/folder/file.ext

.. _wget_mirror_site:

``wget`` 镜像网站目录
===========================

wget镜像网站目录 ``-m`` ，不过如果单纯使用这个参数可能会下载太多的非目标网站的内容(毕竟每个页面链接可能引用了太多站外内容)，所以通常会结合一些限制参数:

- ``--mirror`` ( ``-m`` ): 递归下载资源
- ``--convert-links`` ( ``-k`` ) : 转换所有链接(例如CSS)，以适合离线浏览
- ``--adjust-extension`` ( ``-E`` ): 根据文件内容为文件添加后缀( ``html`` 或 ``css`` )
- ``--page-requisites`` ( ``-p`` ): 下载页面离线显示需要的CSS以及图片
- ``--no-parent`` ( ``-np`` ) : 当执行递归时不上升到父目录，这对于限制仅下载网站的部分内容很有用

这里最重要的结合参数是 ``--no-parent`` ，避免下载太多不必要的内容

上述参数的组合可以缩写为 ``-mkEpnp`` 举例，在 :ref:`deploy_sles15sp4_gluster11_client` 时，从官方仓库镜像下载 ``gluster-11`` rpm包:

.. literalinclude:: ../../gluster/deploy/suse/deploy_sles15sp4_gluster11_client/wget_mirror_gluster_sles15sp4
   :caption: 使用 :ref:`wget` 镜像网站方式下载GlusterFS 11 for SLES 15SP4

按照文件中url内容来下载文件
=============================

在 :ref:`lfs_prepare` 中采用一个url列表文件来下载对应软件包:

.. literalinclude:: ../lfs/lfs_prepare/wget
   :caption: 下载所有 wget-list-sysv 列出的软件包和补丁

.. _wget_proxy:

``wget`` 代理
================

``wgetrc`` 配置
-------------------

``/etc/wgetrc`` 或者 ``~/.wgetrc`` 都可以为 ``wget`` 配置代理:

.. literalinclude:: wget/wgetrc
   :caption: ``/etc/wgetrc`` 或者 ``~/.wgetrc`` 配置代理

命令行参数
--------------

``wget`` 命令的 ``-e`` 参数可以传递 ``wgetrc`` 配置，这样就可以代替配置文件:

.. literalinclude:: wget/wget_proxy
   :caption: 直接命令行 ``-e`` 参数传递代理配置

参考
====

- `How to specify the location with wget? <https://stackoverflow.com/questions/1078524/how-to-specify-the-location-with-wget>`_
- `Make Offline Mirror of a Site using wget <https://www.guyrutenberg.com/2014/05/02/make-offline-mirror-of-a-site-using-wget/>`_
- `How do I force wget to use a proxy server without modifying system files? [duplicate] <https://askubuntu.com/questions/346649/how-do-i-force-wget-to-use-a-proxy-server-without-modifying-system-files>`_
