.. _build_ceph:

==================
编译Ceph
==================

我在 :ref:`install_mobile_cloud_ceph` 时，物理主机是基于 :ref:`arch_linux` 的 :ref:`asahi_linux` 系统，官方仓库没有提供 ``ceph`` 。虽然能够通过 :ref:`archlinux_aur` 安装，但是我发现安装依赖太多，甚至需要安装Java JRE。

所以，我考虑从源代码编译，毕竟我只需要用于 :ref:`libvirt` 的RBD客户端。

编译
========

- 下载和 :ref:`install_mobile_cloud_ceph` 服务端相同版本 ``v17.2.5`` ::

   tar xfz ceph-17.2.5.tar.gz
   cd ceph-17.2.5

- 提供了针对deb或rpm的发行版编译方式(未实践)::

   ./make-dist

.. note::

   对于debian/ubuntu系，提供了一个编译依赖列表，可以直接先安装::

      sudo apt-get install `cat doc_deps.deb.txt`

   然后再编译

.. note::

   由于时间和精力有限，暂时没有时间继续折腾，我暂时放弃自己编译ceph，还是采用 :ref:`archlinux_aur` 进行安装

参考
========

- `Github - ceph/ceph: building-ceph <https://github.com/ceph/ceph#building-ceph>`_
- `Github: mikulely/install_ceph.sh <https://gist.github.com/mikulely/25bd8dcfc65c69648234>`_ 提供了一个在 :ref:`arch_linux` 上编译Ceph的参考，其中有编译依赖可以借鉴
