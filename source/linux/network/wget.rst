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

上述参数的组合可以缩写为 ``-mkEpnp``

参考
====

- `How to specify the location with wget? <https://stackoverflow.com/questions/1078524/how-to-specify-the-location-with-wget>`_
- `Make Offline Mirror of a Site using wget <https://www.guyrutenberg.com/2014/05/02/make-offline-mirror-of-a-site-using-wget/>`_
