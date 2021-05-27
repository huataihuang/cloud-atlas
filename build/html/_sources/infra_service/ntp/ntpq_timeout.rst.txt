.. _ntpq_timeout:

=============================
ntpq错误"Request timed out"
=============================

ntpq查询
=========

通常我们在服务器上部署了ntpd服务，会配置和上游NTP服务器进行时钟同步，确保服务器时钟准确。不过，有时候发现服务器时间依然偏移，我们会使用 ``ntpq`` 工具进行查询排查::

   ntpq -np

正常情况下，会打印出当前服务器使用的上游NTP服务器的状态以及是否可访问

但是有时候你也可能看到奇怪的输出::

   localhost: timed out, nothing received
   ***Request timed out

这种情况，你可以尝试检查本地ntpd服务::

   systemctl status ntpd

如果看到类似如下输出::

   ...ntpd[24065]: restrict: error in address '::' on line 13. Ignoring...

则需要怀疑是 IPv6 引发的问题

IPv6和restrict
=================

早期 ``ntp`` 软件包（例如 ``RHEL 5`` ）中 ``restrict default ignore`` 只限制 ``IPv4``。所以早期版本配置中会有两行 ``restrict default`` 和 ``restrict -6 default`` 分别用来限制IPv4和IPv6。

很多系统管理员习惯使用IPv4，所以往往在内核配置中关闭了IPv6支持以避免早期版本的一些奇怪的网络问题。很不巧，早期版本操作系统，例如CentOS 5，即使操作系统没有启用IPv6，这里的 ``restrict -6 default`` 不会报错也不产生影响。

但是，当操作系统升级到 ``RHEL 6.5`` 之后，ntp版本升级到了 ``4.2.4`` ，则 ``restrict default`` 配置行将同时限制IPv4和IPv6，如果操作系统是关闭IPv6就会导致异常查询。

解决的方法是修正 ``ntp.conf`` 配置，去除不需要且影响运行的IPv6相关配置，并显式指定只使用IPv4，即将原配置::

   restrict default ignore
   restrict -6 default ignore

修改成::

   restrict -4 default ignore

然后重启 ``ntpd`` 服务::

   service ntpd restart

再进行NTP查询就能够正常工作::

   ntpq -np

输出类似::

        remote           refid      st t when poll reach   delay   offset  jitter
   ==============================================================================
    59.37.9.151     .INIT.          16 u    -   64    0    0.000    0.000   0.000
   *127.127.1.0     .LOCL.           5 l    8   64  177    0.000    0.000   0.000

参考
=====

- `'ntpq> peers' gives error "Request timed out" after upgrading to ntp-4.2.6p5 package <https://access.redhat.com/solutions/625863>`_
- `timed out, nothing received <https://unix.stackexchange.com/questions/118865/timed-out-nothing-received>`_
- `Understanding the ntpd Configuration File <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/s1-Understanding_the_ntpd_Configuration_File.html>`_
