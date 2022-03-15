.. _termux_proxy:

==========================
Termux环境安装配置代理
==========================

在移动办公中，需要能够使用Android ( :ref:`pixel_3` )实现:

- Android系统VPN构建起访问安全网络，然后在手机内部运行代理实现网络自由访问
- 提供翻墙代理，例如帮助 :ref:`homebrew` 完成安装

安足squid
==============

在 :ref:`termux` 中直接使用 ``apt`` 可以安装 :ref:`squid` ::

   apt install squid

配置squid
============

在 :ref:`termux` 环境中运行的应用程序是采用 ``chroot`` 方式运行，所以所有运行程序和配置都位于 ``termux`` 的环境目录下，通过直接执行 ``squid`` 命令直接运行之后，就可以看到相关目录 ( ``ps aux | grep squid`` )位于::

   u0_a299  25971  0.0  0.0 11103956 568 ?        S<s   1970   0:00 squid
   u0_a299  26359  3.3  0.2 10979324 7752 ?       S<    1970   4:57 (squid-1) --kid squid-1
   u0_a299  26367  0.0  0.0 10786804 1056 ?       S<    1970   0:00 (logfile-daemon) /data/data/com.termux/files/usr/var/log/squid/access.log

对应配置文件是 ``/data/data/com.termux/files/usr/etc/squid/squid.conf`` ，配置采用 :ref:`squid_socks_peer` 相同的本地squid配置:

.. literalinclude:: ../../web/proxy/squid/squid_socks_peer/squid_liberty.conf
   :linenos:
   :caption: squid_liberty.conf - 本地转发墙外squid
