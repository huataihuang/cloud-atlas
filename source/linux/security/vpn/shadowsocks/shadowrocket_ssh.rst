.. _shadowrocket_ssh:

==========================
Shadowrocket使用SSH
==========================

.. warning::

   Shadowrocket也能够使用 :ref:`ssh_tunneling_dynamic_port_forwarding` 来实现快速的VPN连接，但是很不幸，由于SSH协议握手明文特征以及SS的特征，目前GFW防火墙似乎已经能够通过深度包检测发现并断开连接，我实际验证这个方法无法翻墙。

   这个实验只能在局域网内部完成，或者家用HomeLab如果有公网固定IP地址可以使用。
