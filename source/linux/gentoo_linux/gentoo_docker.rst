.. _gentoo_docker:

===================
Gentoo Docker
===================

:ref:`docker` 作为容器化运行环境，可以方便开发和部署，并且由于不是 :ref:`kvm` 这样的完全虚拟化，直接使用了物理主机 :ref:`kernel` ，能够获得轻量级和高性能的优势。

.. note::

   我的Docker存储引擎采用 :ref:`docker_zfs_driver` ，所以部署会在 :ref:`gentoo_zfs` 完成之后进行

内核
======

参考
======

- `gentoo linux wiki: Docker <https://wiki.gentoo.org/wiki/Docker>`_
