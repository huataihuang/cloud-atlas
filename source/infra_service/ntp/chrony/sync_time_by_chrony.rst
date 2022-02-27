.. _sync_time_by_chrony:

=====================
使用chrony同步时间
=====================

正如 :ref:`ntp_quickstart` 所述，chrony作为Linux平台强壮的ntp实现，已经逐渐成为各大发行版采用的主流NTP服务，适合二级NTP服务器，并且适合间断性网络连接的服务器时钟同步。

.. note::

   Red Hat的RHEL使用 Chrony 作为NTP服务器，并且在官方手册中提供了非常详尽的 `CONFIGURING NTP USING THE CHRONY SUITE <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite>`_ 指南。后续我将根据该手册做完整的实践

参考
======

- `How to Sync Time in Linux Server using Chrony <https://www.linuxtechi.com/sync-time-in-linux-server-using-chrony/>`_
- `Manage NTP with Chrony <https://opensource.com/article/18/12/manage-ntp-chrony>`_
