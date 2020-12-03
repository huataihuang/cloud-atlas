.. _pi4_usb3_wifi2.4ghz:

===================================
树莓派4使用USB3影响WiFi 2.4GHz问题
===================================

.. note::

   在树莓派4上使用USB 3.0接口会影响2.4GHz频率的无线网络连接，这个问题不是树莓派独有的故障，而是USB 3.0自身实现的限制。

在使用树莓派4的USB 3.0接口进行数据传输时，你会发现严重影响2.4GHz无线网络。这种情况仅发生在USB 3 + 2.4GHz连接时，此时2.4GHz无线网络甚至不能被看到，或者在USB3检测时(启动时候或者USB连接时)无线网络完全丢失。

树莓派4甚至是一个2.4GHz无线干扰设备，因为树莓派的USB3接口和HDMI接口非常靠近WiFi天线(位于主板上方接近GPIO插线1-6)。较差的屏蔽(网线或者连接器)会放大这个问题，但是即使使用非常好的网线也不能消除这个问题。所以，如果需要使用USB3接口( :ref:`choice_pi_storage` 使用USB接口 )建议不要在树莓派4上使用2.4GHz WiFi连接，而是采用 `Pi4 + USB3 + 5GHz WiFi` 组合。

.. note::

   请注意 :ref:`wpa_supplicant` 在连接5GHz WiFi需要明确设置 ``country=CN`` ，这是我实践过程中的一个惨痛教训。

参考
======

- `Pi4, USB3, and Wireless 2.4Ghz interference <https://www.indilib.org/forum/general/6576-pi4-usb3-and-wireless-2-4ghz-interference.html>`_
