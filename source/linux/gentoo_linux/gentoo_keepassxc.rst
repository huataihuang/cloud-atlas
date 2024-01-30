.. _gentoo_keepassxc:

===================
Gentoo KeepassXC
===================

在Gentoo平台，主要的密码管理工具:

- KeepassXC 只依赖QT运行，支持Keepass不同格式
- GNOME Secrets 也同样支持Keepass不同格式，但是没有在主仓库提供安装

我虽然想安装使用KeepassXC，但是我不想有非常大的依赖，所以我准备后期采用 FlatHub 来完成安装部署。

.. _gentoo_keepassxc_uninstall:

gentoo卸载keepassxc
=======================

我在尝试卸载 ``keepassxc`` 时遇到问题:

.. literalinclude:: gentoo_keepassxc/uninstall
   :caption: 卸载 ``keepassxc``
   
.. literalinclude:: gentoo_keepassxc/uninstall_output
   :caption: 卸载 ``keepassxc`` 报错信息
   :emphasize-lines: 3
   
查看 `virtual/secret-service/secret-service-0.ebuild <https://gitweb.gentoo.org/repo/gentoo.git/tree/virtual/secret-service/secret-service-0.ebuild>`_ 可以看到:

.. literalinclude:: gentoo_keepassxc/depend
   :caption: keepassx的依赖
   
也就是说要么依赖 ``gnome-keyring`` 要么依赖 ``keepassxc`` ，所以执行 ``oneshot`` 替换安装:

.. literalinclude:: gentoo_keepassxc/oneshot
   :caption: 通过 ``--oneshot`` 参数安装 ``gnome-keyring`
   
这样 ``gnome-keyring`` 就能取代 ``keepassxc`` ，此时再次执行卸载 ``keepassxc`` 就能成功

参考
==========

- `gentoo wiki: Substituting a source based dependency for "-bin" version <https://wiki.gentoo.org/wiki/Minimizing_compilation_and_installation_time>`_
