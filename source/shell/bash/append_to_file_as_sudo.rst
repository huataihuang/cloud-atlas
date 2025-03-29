.. _append_to_file_as_sudo:

=============================
采用sudo方式向文件添加内容
=============================

在shell命令行中，有时候需要给一个 ``root`` 用户的文件添加内容，但是当前shell执行用户是普通用户身份，则会出现如下执行权限不足的报错::

   $ echo "export PATH=$PATH:/opt/bin" >> /etc/profile
   -bash: /etc/profile: Permission denied

解决的方法有以下两种:

- 使用 ``sudo tee -a`` 命令，通过管道传递需要添加的内容给 ``tee`` ，由于 ``tee`` 通过 ``sudo`` 执行，就具有权限写入文件::

   echo "export PATH=$PATH:/opt/bin" | sudo tee -a /etc/profile

- 使用 ``sudo bash -c`` 命令，使得整个shell都具有 ``root`` 用户权限::

   sudo bash -c "echo 'export PATH=$PATH:/opt/bin' >> /etc/profile"

参考
======

- `How to append to a file as sudo? <http://superuser.com/questions/136646/how-to-append-to-a-file-as-sudo>`_
