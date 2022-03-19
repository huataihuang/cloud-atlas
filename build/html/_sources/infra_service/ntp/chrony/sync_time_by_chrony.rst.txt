.. _sync_time_by_chrony:

=====================
使用chrony同步时间
=====================

正如 :ref:`ntp_quickstart` 所述，chrony作为Linux平台强壮的ntp实现，已经逐渐成为各大发行版采用的主流NTP服务，适合二级NTP服务器，并且适合间断性网络连接的服务器时钟同步。

.. note::

   Red Hat的RHEL使用 Chrony 作为NTP服务器，并且在官方手册中提供了非常详尽的 `CONFIGURING NTP USING THE CHRONY SUITE <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite>`_ 指南。后续我将根据该手册做完整的实践

chronyc客户端时间同步
=======================

如果主机时间和NTP服务器的时间差距太大，例如我在 :ref:`alpine_install_pi_1` 遇到树莓派因为没有硬件时钟启动时时间偏差极大 ，则 ``chronyd`` 服务启动时不会自动矫正时间(或者矫正需要很久)，此时，可以使用 ``chronyc`` 客户端强制将主机时间矫正::

   chronyc -a makestep

此时提示::

   200 OK

则再检查主机时间就会看到时间已经正确。

参考
======

- `How to Sync Time in Linux Server using Chrony <https://www.linuxtechi.com/sync-time-in-linux-server-using-chrony/>`_
- `Manage NTP with Chrony <https://opensource.com/article/18/12/manage-ntp-chrony>`_
- `Time Synchronization (Chrony) <https://docs.oracle.com/cd/E90981_01/E90982/html/chrony.html>`_
