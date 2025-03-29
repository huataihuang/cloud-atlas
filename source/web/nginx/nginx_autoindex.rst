.. _nginx_autoindex:

====================================
Nginx 列出目录中文件(autoindex)
====================================

默认情况下，出于安全需求，Nginx和 :ref:`apache` 都是默认关闭 ``autoindex`` 功能的。也就是说，如果目录中没有提供 ``index.html`` ，则不会自动列出目录下所有文件(类似文件浏览器)。

不过，有时候，我们也需要快速能否展示服务器上文件，方便通过浏览器下载文件。方法非常简单，但是也值得记住:

.. literalinclude:: nginx_autoindex/nginx.conf
   :caption: 配置简单的文件索引功能启用
   :emphasize-lines: 11

如果需要限制为某个子目录，可以使用如下格式

.. literalinclude:: nginx_autoindex/nginx_subdir.conf
   :caption: 配置子目录的文件索引功能

参考
=======

- `How to enable directory listing in Nginx? Setting up nginx to list files and folders in a directory. <https://umutcanbolat.com/how-to-enable-directory-listing-in-nginx/>`_
