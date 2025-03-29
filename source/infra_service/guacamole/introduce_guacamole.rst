.. _introduce_guacamole:

=====================
Apache Guacamole简介
=====================

.. note::

   Apache Guacamole 是一个完整复杂的远程桌面网关解决方案，适合作为集群的服务输出。我考虑如下场景:

   - 将 Guacamole 作为KVM虚拟机的VNC集中管理，方便远程管理虚拟机
   - 部署 :ref:`kubernetes` 集的 Guacamole 来集中管理 :ref:`kata` 中的众多Windows虚拟机

   如果只是单机无客户端远程桌面，可以参考 :ref:`kali_novnc`

   如果期望将远程服务器上的图形程序 **融入** 本地桌面，可以考虑 :ref:`xpra`

参考
======

- `Apache Guacamole Introduction <https://guacamole.apache.org/doc/gug/preface.html>`_
