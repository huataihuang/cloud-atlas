.. _systemd_timesyncd:

======================
Systemd Timesyncd服务
======================

现代Linux发行版都采用systemd管理系统，systemd体系也提供了基础的 ``timesyncd`` 服务来实现SNTP客户端，可以替代传统的 ``ntpd`` 来实现主机NTP同步(客户端)。虽然不能作为NTP服务器，但是精简的 ``systemd-timesyncd`` 可以实现非常轻量级的时钟同步功能。

配置timedatectl和timesyncd
=============================

- 使用 ``timedatectl status`` 可以检查时钟状况::

   timedatectl status

输出显示::

         Local time: Tue 2018-05-01 21:54:24 CST
     Universal time: Tue 2018-05-01 13:54:24 UTC
           RTC time: Tue 2018-05-01 13:54:24
          Time zone: Asia/Shanghai (CST, +0800)
    Network time on: yes
   NTP synchronized: yes
    RTC in local TZ: no

- 检查时钟同步情况::

   systemctl status systemd-timesyncd

显示输出::

   ● systemd-timesyncd.service - Network Time Synchronization
      Loaded: loaded (/lib/systemd/system/systemd-timesyncd.service; enabled; vendor preset: enabled)
     Drop-In: /lib/systemd/system/systemd-timesyncd.service.d
              └─disable-with-time-daemon.conf
      Active: active (running) since Mon 2018-04-16 10:33:42 CST; 2 weeks 1 days ago
        Docs: man:systemd-timesyncd.service(8)
    Main PID: 910 (systemd-timesyn)
      Status: "Synchronized to time server 91.189.91.157:123 (ntp.ubuntu.com)."
       Tasks: 2
      Memory: 2.2M
         CPU: 2.710s
      CGroup: /system.slice/systemd-timesyncd.service
              └─910 /lib/systemd/systemd-timesyncd
   
   Apr 29 07:30:24 devstack systemd-timesyncd[910]: Timed out waiting for reply from 91.189.91.157:123 (ntp.ubuntu.com).
   Apr 29 07:30:24 devstack systemd-timesyncd[910]: Synchronized to time server 91.189.94.4:123 (ntp.ubuntu.com).
   Apr 29 09:14:36 devstack systemd-timesyncd[910]: Timed out waiting for reply from 91.189.94.4:123 (ntp.ubuntu.com).
   Apr 29 09:14:46 devstack systemd-timesyncd[910]: Timed out waiting for reply from 91.189.89.198:123 (ntp.ubuntu.com).
   Apr 29 09:14:56 devstack systemd-timesyncd[910]: Timed out waiting for reply from 91.189.89.199:123 (ntp.ubuntu.com).
   Apr 29 09:49:06 devstack systemd-timesyncd[910]: Synchronized to time server 91.189.89.199:123 (ntp.ubuntu.com).
   Apr 29 13:52:01 devstack systemd-timesyncd[910]: Timed out waiting for reply from 91.189.89.199:123 (ntp.ubuntu.com).
   Apr 29 13:52:11 devstack systemd-timesyncd[910]: Timed out waiting for reply from 91.189.89.198:123 (ntp.ubuntu.com).
   Apr 29 13:52:21 devstack systemd-timesyncd[910]: Timed out waiting for reply from 91.189.94.4:123 (ntp.ubuntu.com).
   Apr 29 13:52:22 devstack systemd-timesyncd[910]: Synchronized to time server 91.189.91.157:123 (ntp.ubuntu.com).

- 在 ``/etc/systemd/timesyncd.conf`` 设置 ``timedatectl`` 和 ``timesyncd`` 获取时钟值的服务器，并且详细配置可以在 ``/etc/systemd/timesyncd.conf.d/`` 目录下找到

- 在 ``/etc/systemd/timesyncd.conf`` 中配置了 ``timedatectl`` 访问的服务器，这里配置局域网中自建的 :ref:`deploy_ntp` ::

   [Time]
   NTP=192.168.6.11

- 重启 ``systemd-timesyncd`` 服务::

   sudo systemctl restart systemd-timesyncd

- 检查和指定NTP服务器同步时间::

   systemctl status systemd-timesyncd

可以看到同步过程::

   ...
   May 01 22:38:36 pi1 systemd[1]: Starting Network Time Synchronization...
   May 01 22:38:37 pi1 systemd[1]: Started Network Time Synchronization.
   May 01 22:38:37 pi1 systemd-timesyncd[23922]: Synchronized to time server 192.168.6.11:123 (192.168.6.11).
