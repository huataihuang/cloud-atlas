.. _wget:

========
wget
========

wget是常用下载工具

- wget下载文件到指定目录 ``-P prefix`` ::

   -P prefix
   --directory-prefix=prefix
              Set directory prefix to prefix.  The directory prefix is the
              directory where all other files and sub-directories will be
              saved to, i.e. the top of the retrieval tree.  The default
              is . (the current directory).

举例::

   wget <file.ext> -P /path/to/folder

- wget下载文件到指定目录下文件名 ``-O filename`` ::

   -O file
   --output-document=file
       The documents will not be written to the appropriate files, but all will be
       concatenated together and written to file.  If - is used as file, documents will be
       printed to standard output, disabling link conversion.  (Use ./- to print to a file
       literally named -.)

举例::

   wget <file.ext> -O /path/to/folder/file.ext

-  wget镜像网站目录 ``-m``

参考
====

- `How to specify the location with wget? <https://stackoverflow.com/questions/1078524/how-to-specify-the-location-with-wget>`_

