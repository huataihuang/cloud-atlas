.. _fedora_autoupdates:

===================
Fedora系统自动更新
===================

和 :ref:`ubuntu_unattended_upgrade` 相似，Fedora也有自动 :ref:`dnf` 更新方法，可以方便我们维护大量的Red Hat Linux。

.. note::

   对于关键性服务器，建议不要启用自动更新，以免导致兼容性故障。对于生产关键性服务器，应该采用严格的测试和灰度，并自己把控更新方式。

``dnf-automatic`` 软件包提供了 :ref:`dnf` 组件自动更新服务

- 安装 ``dnf-automatic`` :

.. literalinclude:: fedora_autoupdates/dnf_install_dnf-automatic
   :language: bash
   :caption: 在Fedora系统中安装dnf-automatic

- 默认情况下 ``dnf-automatic`` 只是下载软件包，但是不安装，所以需要修订 ``/etc/dnf/automatic.conf`` :

.. literalinclude:: fedora_autoupdates/enable_dnf-automatic_apply
   :language: bash
   :caption: 激活dnf-automatic自动安装补丁

- 运行并激活 :ref:`systemd` 的 ``dnf-automatic.timer`` 定时器:

.. literalinclude:: fedora_autoupdates/enable_systemd_dnf-automatic.timer
   :language: bash
   :caption: 运行并激活dnf-automatic.timer

参考
=======

- `Fedora Quick Docs / Adding and managing software / AutoUpdates <https://docs.fedoraproject.org/en-US/quick-docs/autoupdates/>`_ 
