.. _systemd_timesyncd:

======================
Systemd Timesyncd服务
======================

现代Linux发行版都采用systemd管理系统，systemd体系也提供了基础的 ``timesyncd`` 服务来实现SNTP客户端，可以替代传统的 ``ntpd`` 来实现主机NTP同步(客户端)。虽然不能作为NTP服务器，但是精简的 ``systemd-timesyncd`` 可以实现非常轻量级的时钟同步功能。

``systemd-timesyncd`` 是通过网络提供系统时钟同步的服务，实现了SNTP client。和NTP实现 :ref:`chrony` 不同， ``systemd-timesyncd`` 只实现客户端功能，而不是实现完整的NTP，聚焦于从远程服务器查询时间并同步到本地时钟。除非你需要需要为网络中其他NTP客户端提供服务或者需要连接本地硬件时钟，否则一个简单的NTP客户端，例如 ``systemd-timesyncd`` ，往往是最好的解决方案。这个时钟同步客户端运行只需要最小的权限，并且只有网络连接可用时才会通过
:ref:``systemd_networkd`` hook up。每次新的NTP同步请求发起， ``timesyncd`` 服务就把当前时钟保存到磁盘，并使用它来矫正启动时的系统时钟，这样就适合用于缺少RTC的设备，例如 :ref:`raspberry_pi` 或者嵌入设备，可以确保这些系统时钟正确(即使不是始终正确)。需要注意，在安装 :ref:`systemd` 时候需要确保创建一个名为 ``systemd-timesync`` 的用户和组。

配置
========

- 安装::

   yum install systemd-timesyncd

- 激活::

   systemctl enable systemd-timesyncd.service
   systemctl start systemd-timesyncd.service

当 ``systemd-timesyncd`` 启动时会读取 ``/etc/systemd/timesyncd.conf`` 配置，所以如果要修订配置，例如更改时钟服务器，则类似::

   [Time]
   NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
   FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org

- 要验证配置，执行::

   timedatectl show-timesync --all

显示类似::

   LinkNTPServers=
   SystemNTPServers=
   FallbackNTPServers=0.rhel.pool.ntp.org 1.rhel.pool.ntp.org 2.rhel.pool.ntp.org 3.rhel.pool.ntp.org
   ServerName=0.rhel.pool.ntp.org
   ServerAddress=124.108.20.1
   RootDistanceMaxUSec=5s
   PollIntervalMinUSec=32s
   PollIntervalMaxUSec=34min 8s
   PollIntervalUSec=32s
   NTPMessage={ Leap=0, Version=4, Mode=4, Stratum=2, Precision=-25, RootDelay=19.866ms, RootDispersion=1.800ms, Reference=D8DAC0CA, OriginateTimestamp=Fri 2021-05-28 16:23:26 CST, ReceiveTimestamp=Fri 2021-05-28 16:23:34 CST, TransmitTimestamp=Fri 2021-05-28 16:23:34 CST, DestinationTimestamp=Fri 2021-05-28 16:23:26 CST, Ignored=no PacketCount=1, Jitter=0  }
   Frequency=0


timedatectl和timesyncd
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

如果上述显示输出中::

                  Local time: Fri 2021-05-28 16:24:59 CST
              Universal time: Fri 2021-05-28 08:24:59 UTC
                    RTC time: Fri 2021-05-28 16:24:57
                   Time zone: Asia/Shanghai (CST, +0800)
   System clock synchronized: yes
                 NTP service: inactive
             RTC in local TZ: yes
   
   Warning: The system is configured to read the RTC time in the local time zone.
            This mode cannot be fully supported. It will create various problems
            with time zone changes and daylight saving time adjustments. The RTC
            time is never updated, it relies on external facilities to maintain it.
            If at all possible, use RTC in UTC by calling
            'timedatectl set-local-rtc 0'.    

可以看到::

                 NTP service: inactive
   
实际上没有激活，所以我们通过以下命令激活::

   timedatectl set-ntp true

然后再次检查 ``timedatectl status`` 可以看到::

   ...
                 NTP service: active
   ...

此外，按照提示，关闭从本地时区读取RTC时间::

   timedatectl set-local-rtc 0

完成后再次检查  ``timedatectl status`` 可以看到::

                  Local time: Fri 2021-05-28 16:29:18 CST
              Universal time: Fri 2021-05-28 08:29:18 UTC
                    RTC time: Fri 2021-05-28 08:29:18
                   Time zone: Asia/Shanghai (CST, +0800)
   System clock synchronized: yes
                 NTP service: active
             RTC in local TZ: no

- 检查服务详细信息::

   timedatectl timesync-status

可以看到类似输出::

          Server: 124.108.20.1 (0.rhel.pool.ntp.org)
   Poll interval: 1min 4s (min: 32s; max 34min 8s)
            Leap: normal
         Version: 4
         Stratum: 2
       Reference: D8DAC0CA
       Precision: 1us (-25)
   Root distance: 11.275ms (max: 5s)
          Offset: -14.956ms
           Delay: 186.719ms
          Jitter: 0
    Packet count: 1
       Frequency: +28.703ppm

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

参考
=======

- `systemd-timesyncd <https://wiki.archlinux.org/title/systemd-timesyncd>`_
