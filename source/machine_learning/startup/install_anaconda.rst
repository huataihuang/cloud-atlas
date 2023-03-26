.. _install_anaconda:

====================
安装Anaconda
====================

.. note::

   安装运行环境是 :ref:`fedora` ，我在本文实践基础上，构建 :ref:`fedora_tini_image` 包含Anaconda

- 下载Anaconda Installer并执行安装:

.. literalinclude:: install_anaconda/anaconda.sh
   :language: bash
   :caption: 下载和运行Anaconda Installer

按照提示接受license并且按照默认执行 ``init`` 即可

- 再次登陆系统，或者直接执行::

   source ~/.bashrc

此时就进入了Anaconda的 :ref:`virtualenv` 就可以使用 ``conda`` 命令，例如 ``conda list`` 可以查看安装好的Anaconda包

参考
=======

- `How To Install Anaconda on Fedora 37/36/35 <https://tecadmin.net/how-to-install-anaconda-on-fedora/>`_
- `Anaconda Documentation: Installing on Linux <https://docs.anaconda.com/anaconda/install/linux/>`_
