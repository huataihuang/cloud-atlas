.. _dhcpcd:

===================
dhcpcd
===================

.. _dhcpcd_set_static_dns:

dhcpcd配置静态DNS
===================

通常DHCP会为网络接口分配IP地址同时提供DNS配置，但是有时候只想获取动态IP，但是不希望自己配置的DNS设置被 ``dhcpcd`` 覆盖。此时配置方法类似 :ref:`raspbian_static_ip` ，但是只设置dns部分，不设置IP部分:

.. literalinclude:: dhcpcd/dhcpcd_static_dns.conf
   :caption: 配置静态DNS服务器的 ``/etc/dhcpcd.conf``
   :emphasize-lines: 3

重启 ``dhcpcd`` 服务之后，检查 ``/etc/resolv.conf`` 可以看到如下:

.. literalinclude:: dhcpcd/dhcpcd_static_dns_resolv.conf
   :caption: ``dhcpcd`` 采用静态DNS设置生成的 ``/etc/resolv.conf``
   :emphasize-lines: 3-5

.. note::

   这里 ``dhcpcd`` 生成的 ``/etc/resolv.conf`` 注释中说明有 ``/etc/resolv.conf.head`` 和 ``/etc/resolv.tail`` 配置文件，分别可以定制替换上下两部分内容。(自定义注释?)

参考
======

- `I use only dhcpcd and I want to make /etc/resolv.conf add search domain.local <https://unix.stackexchange.com/questions/557571/i-use-only-dhcpcd-and-i-want-to-make-etc-resolv-conf-add-search-domain-local>`_
