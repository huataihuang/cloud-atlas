.. _iptables_startup:

=========================
iptables快速起步
=========================

显示iptables规则
=====================

- 列出所有激活的iptables规则，使用 ``-S`` 参数::

   iptables -S

以下是安装了docker服务器的ubuntu主机::

   -P INPUT ACCEPT
   -P FORWARD DROP
   -P OUTPUT ACCEPT
   -N DOCKER
   -N DOCKER-ISOLATION-STAGE-1
   -N DOCKER-ISOLATION-STAGE-2
   -N DOCKER-USER
   -A FORWARD -j DOCKER-USER
   -A FORWARD -j DOCKER-ISOLATION-STAGE-1
   -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
   -A FORWARD -o docker0 -j DOCKER
   -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
   -A FORWARD -i docker0 -o docker0 -j ACCEPT
   -A DOCKER-ISOLATION-STAGE-1 -i docker0 ! -o docker0 -j DOCKER-ISOLATION-STAGE-2
   -A DOCKER-ISOLATION-STAGE-1 -j RETURN
   -A DOCKER-ISOLATION-STAGE-2 -o docker0 -j DROP
   -A DOCKER-ISOLATION-STAGE-2 -j RETURN
   -A DOCKER-USER -j RETURN

- 上述是FORWARD表链，对于NAT需要增加参数 ``-t nat`` ，则可以看到 NAT 规则::

   iptables -t nat -S

对于安装docker服务的ubuntu主机::

   -P PREROUTING ACCEPT
   -P INPUT ACCEPT
   -P OUTPUT ACCEPT
   -P POSTROUTING ACCEPT
   -N DOCKER
   -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
   -A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
   -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
   -A DOCKER -i docker0 -j RETURN

以表的方式列出规则
===================

- ``-L`` 参数列出规

参考
=========

- `How To List and Delete Iptables Firewall Rules <https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules>`_
