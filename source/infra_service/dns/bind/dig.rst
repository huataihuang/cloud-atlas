.. _dig:

============
dig
============

dig的TCP模式查询
================

在 :ref:`docker_run_coredns` ，通过 ``docker run`` 将 :ref:`coredns` 服务的TCP端口映射出对外提供服务。此时通过默认UDP端口53是无法访问服务的(需要配置 :ref:`k8s_node-local-dns_force_tcp` )，所以使用dig验证时也要传递 ``+tcp`` 参数:

.. literalinclude:: dig/dig_tcp
   :language: bash
   :caption: dig的 ``+tcp`` 参数可以采用TCP方式查询DNS解析

参考
=======

- `DNS dig +tcp OK, udp NO <https://superuser.com/questions/591833/dns-dig-tcp-ok-udp-no>`_
