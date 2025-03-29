.. _pixel_3_usb_audio:

===========================
Pixel 3 USB C接口音频输出
===========================

Pixel 3取消了之前 :ref:`pixel` 所具备的 3.5mm 音频输出接口，只有一个 USB type-c 接口输出。那么这个USB type-c接口是否可以使用转换器连接旧有的 3.5mm 耳机呢？

我原本以为这是一个简单的事情，毕竟我在 :ref:`iphone12_mini` 和 :ref:`iphone_se1` 都使用过lightning转3.5mm的转换器，使用上并没有什么不便。

但是，在淘宝上买了绿联的 ``typec转3.5mm`` 转换器(29.9元)，插到 :ref:`pixel_3` 上，系统通知却提示::

   Analog audio accessory detected

   The attached device is not compatible with this phone.

原因是: Pixel系列设备没有 ``模拟音频输出`` (ananlog audio output)。也就是说，需要使用内置数字音频转模拟音频的芯片的转换器，才能实现将Pixel 3的音频输出。在淘宝上，这种带数模转换芯片的USB type-c转化器是无芯片版本的2倍售价(59.9元)。看来后续还需要做新的尝试...

参考
========

- `I'm Not Able to use earphones Analogue audio accessory detected. The attached device is not compatib <https://support.google.com/pixelphone/thread/65777324/i-m-not-able-to-use-earphones-analogue-audio-accessory-detected-the-attached-device-is-not-compatib?hl=en>`_
