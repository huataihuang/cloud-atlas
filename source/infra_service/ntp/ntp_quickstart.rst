.. _ntp_quickstart:

==================
ntp快速起步
==================

NTP服务是集群最基础、最重要和最容易被忽视的服务，实际上所有网络服务都需要依赖精确是时间和同步，否则会导致应用无法正常工作(例如加密、交易)。

传统上，我们会使用和部署 ``ntpd`` 服务来实现NTP服务器以及确保本地主机时钟精确，不过随着技术发展，衍生出不同的ntp实现：

- chrony: 更强壮的ntp实现，虽然不如 ``ntpd`` 适合所有场景，但是能够稳定在联网和断续联网环境中，适合二级NTP服务器部署
- systemd-timesyncd: 简化版SNTP client，专注于只需要同步本地客户端时间的领域

我将在不同的实践中对上述两个解决方案进行阐述。不过，本文聚焦于经典的 ``ntpd`` 服务以及常用的 ``ntpdate`` 工具。

基础的NTP配置
=============

比较简单的方式：选择集群系统的2台服务器作为NTP服务器，在这两台服务器上设置和Internet上的NTP时间服务器进行同步，并同时对内网系统提供NTP服务。集群系统中所有其他服务器配置以前两台NTP服务器为基准，进行时间同步。（内网服务器通常不能直接访问Internet）

.. note::

   建议至少确保配置两台远程服务器进行同步，以便能够在其中某台服务器宕机情况下依然能够继续和backup服务器同步。不过，实际生产环境，强烈建议至少配置4台NTP服务器，原因见 `Upstream Time Server Quantity <http://support.ntp.org/bin/view/Support/SelectingOffsiteNTPServers#Section_5.3.3.>`_ :

   - 采用4台NTP服务器的好处是：当一台NTP服务器宕机情况下，剩余3台服务器依然能够提供冗余，并且如果3台服务器之间时钟不一致，依然能够按照 ``少数服从多数`` 方式计算判断出哪些NTP服务器时间是较为准确的，以便能够进行同步。
   - 如果采用3台NTP服务器，则宕机1台就会只有2台NTP服务器，而2台NTP服务器是无法判断选择哪个NTP服务器时间更为准确
   - 如果只使用2台NTP服务器，即使没有服务器宕机，也可能无法判断哪个NTP服务器时间更准确
   - 如果使用1台NTP服务器，没有冗余是不能接受的

在主流的RHEL 6.x/7.x 上，通常都已经安装了 ``ntpd`` 服务::

   yum install ntp

NTP程序是通过 ``/etc/ntp.conf`` 或 ``/etc/xntp.conf`` 配置文件配置。

- 配置作为NTP服务器上 ``/etc/ntp.conf`` :

.. literalinclude:: ntp_quickstart/ntp.conf
   :language: bash
   :linenos:
   :caption:

配置说明:

  - ``driftfile /var/lib/ntp/drift`` 配置

  设置 ``drift`` （偏移）文件位置，这个偏移文件只包含一个在每次系统或服务启动时用于调整系统时钟频率的值。这个 ``drift`` 文件是用来存储系统运行在自己名义频率（nominal frequency）和使用UTC同步保留的所需频率之间的频率偏差。如果这个文件存在，这个 ``drift`` 文件包含的值就会在系统启动时读取并用于矫正时钟源。使用 ``drift`` 文件可以降低达到稳定和精确时钟所需的时间。这个值是计算出来的，并且这个文件每个小时都会被 ``ntpd`` 所替换。由于这个 ``drift`` 文件是由 ``ntpd`` 进行更新，所以必须对 ``ntpd`` 这个目录可以读写。

  - ``server`` 配置

  在 ``ntp.conf`` 配置中，最基本有2行 ``server`` 的配置，其中一个 ``server`` 是本地的 ``pseudo IP`` 地址，也就是回环地址 ``127.127.1.0`` ，这个伪IP是为了确保ntpd服务在远程NTP服务器宕机情况下，NTP能够和自己进行同步，直到远程服务器恢复服务就可以开始再次和远程服务器进行同步。

  - ``restrict`` 配置

  ``restrict`` 配置限制了访问你配置的NTP服务器的客户端，提供了一定的安全保护

  如果要表示没有明确允许则禁止访问任何内容，则配置 ``restrict default ignore`` ，需要注意的是，如果配置了这行，则必须明确配置允许的客户端，并且对于自己需要访问的上级NTP服务器也需要明确配置允许，否则会导致无法工作 - 见 `Why NTP is not working when using "restrict default ignore" <https://access.redhat.com/solutions/772683>`_ ::

     restrict default ignore
     server x.y.z.w
     restrict x.y.z.w

  如果没有太严格的安全要求，也可以修订default如下::

     restrict default kod nomodify notrap nopeer noquery
     restrict -6 default kod nomodify notrap nopeer noquery
     restrict 127.0.0.1
     restrict -6 ::1

参考
=====

- `Basic NTP configuration <http://www.tldp.org/LDP/sag/html/basic-ntp-config.html>`_
- `Best practices for NTP <https://access.redhat.com/solutions/778603>`_
