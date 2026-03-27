.. _ubuntu_helix_lsp:

====================================================
Ubuntu环境Helix结合LSP(Language Server Protocol)
====================================================

之前在 :ref:`freebsd_helix_lsp` 实践中遇到一些挫折，我暂时改为采用 :ref:`ubuntu_image` 运行容器中 :ref:`ubuntu_install_helix`

安装Helix
============

使用Helix官方维护的PPA安装Helix:

.. literalinclude:: ../../../linux/ubuntu_linux/admin/apt/software-properties-common
   :caption: 通过安装 ``software-properties-common`` 获得 ``apt-add-repository``

.. literalinclude:: helix_startup/ubuntu_apt_install_helix
   :caption: 通过Helix官方PPA安装helix

.. note::

   为了能够简化环境，我在 :ref:`ubuntu_image` 时，采用复制 ``/etc/apt/sources.list.d/maveonair-ubuntu-helix-editor-noble.sources`` 配置文件来添加仓库进行安装

