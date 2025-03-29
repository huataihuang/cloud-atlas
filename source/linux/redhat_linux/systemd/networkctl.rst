.. _networkctl:

=============
networkctl
=============

networkctl是一个命令行检查网络设备和连接状态的命令行工具，可以用来查询或者控制Linux网络子系统。这是在systemd中引入的新命令。

在运行 ``networkctl`` 之前，需要确保 ``systemd-networkd`` 服务已经运行，否则会出现错误::

   WARNING: systemd-networkd is not running, output will be incomplete.

如果没有启动systemd-networkd，则通过以下命令启动和激活::

   sudo systemctl start systemd-networkd
   sudo systemctlenable systemd-networkd

- 检查所有网络链接和设备额状态::

   networkctl

输出显示::

   IDX LINK  TYPE     OPERATIONAL SETUP      
     1 lo    loopback carrier     unmanaged  
     2 eth0  ether    routable    configured 
     3 wlan0 wlan     no-carrier  configuring

- 可以通过 networkctl 的 status 命令来查看指定连接的类型，状态，内核模块，硬件和IP地址，配置DNS等等。如果没有指定特定连接，则默认只显示可路由连接。

::

   networkctl status

输出显示::

   ●   State: routable                                                      
     Address: 192.168.6.15 on eth0                                          
              fe80::dea6:32ff:fec5:489c on eth0                             
     Gateway: 192.168.6.9 (Wistron Infocomm (Zhongshan) Corporation) on eth0
         DNS: 30.11.17.1                                                    
              30.17.16.1                                                    
              30.17.16.2                                                    
   
   Nov 03 21:47:04 pi-worker1 systemd-networkd[1600]: wlan0: Link DOWN
   Nov 03 21:47:04 pi-worker1 systemd[1]: Started Network Service.
   Nov 03 21:47:04 pi-worker1 systemd-networkd[1600]: wlan0: Link UP
   Nov 03 21:47:04 pi-worker1 systemd[1]: Starting Wait for Network to be Configured...
   Nov 03 21:47:04 pi-worker1 systemd-networkd[1600]: wlan0: IPv6 successfully enabled
   Nov 03 21:47:05 pi-worker1 systemd-networkd[1600]: eth0: IPv6 successfully enabled
   Nov 03 21:47:05 pi-worker1 systemd-networkd[1600]: eth0: Link UP
   Nov 03 21:47:05 pi-worker1 systemd[1]: Finished Wait for Network to be Configured.
   Nov 03 21:47:10 pi-worker1 systemd-networkd[1600]: eth0: Gained carrier
   Nov 03 21:47:11 pi-worker1 systemd-networkd[1600]: eth0: Gained IPv6LL

- 检查链路层发现协议(LLDP, Link Diecovery Discovery Protocol)，则使用 lldp 命令""

   networkctl lldp

systemd-networkd的debug日志
============================

要排查 ``systemd-networkd`` 问题，可以配置该服务开启日志debug，编辑 ``/etc/systemd/system/systemd-networkd.service.d/override.conf`` ::

   [Service]
   Environment=SYSTEMD_LOG_LEVEL=debug

然后执行journalctl 的 ``-u`` 参数指定服务单元，并加上 ``-f`` 进行tail::

   journalctl -u systemd-networkd.service -f

参考
=====

- `Inspecting the Status of Network Links with networkctl <https://vmware.github.io/photon/assets/files/html/3.0/photon_troubleshoot/inspecting-network-links-with-networkctl.html>`_
- `networkctl – Query the Status of Network Links in Linux <https://www.tecmint.com/networkctl-check-linux-network-interface-status/>`_
