.. _pixel_4_volte:

=================================
配置Pixel 4支持VoLTE
=================================

虽然我在调研 :ref:`pixel_4` 的时候隐约看到有报导说Google 2022年释出的更新全面支持了所有运营商的VoLTE，但是实际上拿到Pixel 4手机试用还是发现无法激活VoLTE。

简单来说，在手机拨号中输入 ``*#*#4636#*#*`` ，此时会显示出测试页面，此时可以选择 ``Phone information`` (手机信息)，如果对运营商能够激活VoLTE的话，界面会提供一个设置开关来激活VoLTE。但是，很不幸，和 :ref:`pixel_3_chinese_volte` 类似，无法直接激活，还是需要通过复杂的 :ref:`unlock_bootloader` 并安装 :ref:`magisk` 以及插件来实现激活。

.. note::

   `[Update: Mar. 17] Google Pixel phones still lack VoLTE & Vo-WiFi support in multiple European & Asian countries <https://piunikaweb.com/2023/03/17/google-pixel-phones-lack-volte-in-some-european-and-asian-countries/>`_ 这个blog抱怨了Google在多个欧洲和亚洲国家无法直接激活VoLTE，往往需要hack方式来添加运营商Profile才能开启VoLTE。 `kyujin-cho / pixel-volte-patch <https://github.com/kyujin-cho/pixel-volte-patch>`_ 为Pixel 6/7开启VoLTE，
   

参考
======

- `Pixel 4 enabling VoLTE if option not available <https://www.reddit.com/r/GooglePixel/comments/orzyl8/pixel_4_enabling_volte_if_option_not_available/>`_
- `[Update: Mar. 17] Google Pixel phones still lack VoLTE & Vo-WiFi support in multiple European & Asian countries <https://piunikaweb.com/2023/03/17/google-pixel-phones-lack-volte-in-some-european-and-asian-countries/>`_
- `Enabling VoLTE & VoWifi Pixel 4 <https://xdaforums.com/t/enabling-volte-vowifi-pixel-4.4002611/>`_
- `VoLTE Patch for Pixel 4/4XL <https://github.com/hyx0329/VoLTE-Patch-for-Pixel4>`_ 有人提供了这个patch，待验证
