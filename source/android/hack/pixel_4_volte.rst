.. _pixel_4_volte:

=================================
配置Pixel 4支持VoLTE
=================================

虽然我在调研 :ref:`pixel_4` 的时候隐约看到有报导说Google 2022年释出的更新全面支持了所有运营商的VoLTE，但是实际上拿到Pixel 4手机试用还是发现无法激活VoLTE。

简单来说，在手机拨号中输入 ``*#*#4636#*#*`` ，此时会显示出测试页面，此时可以选择 ``Phone information`` (手机信息)，如果对运营商能够激活VoLTE的话，界面会提供一个设置开关来激活VoLTE。但是，很不幸，和 :ref:`pixel_3_chinese_volte` 类似，无法直接激活，还是需要通过复杂的 :ref:`unlock_bootloader` 并安装 :ref:`magisk` 以及插件来实现激活。

.. note::

   `[Update: Mar. 17] Google Pixel phones still lack VoLTE & Vo-WiFi support in multiple European & Asian countries <https://piunikaweb.com/2023/03/17/google-pixel-phones-lack-volte-in-some-european-and-asian-countries/>`_ 这个blog抱怨了Google在多个欧洲和亚洲国家无法直接激活VoLTE，往往需要hack方式来添加运营商Profile才能开启VoLTE。 `kyujin-cho / pixel-volte-patch <https://github.com/kyujin-cho/pixel-volte-patch>`_ 为Pixel 6/7开启VoLTE，
   
准备工作
==========

- 安装并配置 :ref:`magisk` ，确保 :ref:`pixel_4` 已经完成 ``root`` ( 我的实践采用自己 :ref:`build_lineageos_20_pixel_4` )
- 从 `VoLTE Patch for Pixel 4/4XL <https://github.com/hyx0329/VoLTE-Patch-for-Pixel4>`_ 下载patch包( ``.zip`` ) 传输到手机内部:

.. literalinclude:: pixel_4_volte/adb_push_volte.zip
   :caption: 将 volte 补丁zip包推送到手机存储中

- 使用 :ref:`magisk` 的 ``Modules`` 页面 ``Installed from storage`` 完成安装(非常简单)，安装成功后重启手机，就可以正常使用中国移动的 VoLTE 功能(验证方法是在使用LTE网络上网浏览时拨打电话，电话接通后依然能够通过LTE上网就表明VoLTE功能正常)

参考
======

- `Pixel 4 enabling VoLTE if option not available <https://www.reddit.com/r/GooglePixel/comments/orzyl8/pixel_4_enabling_volte_if_option_not_available/>`_
- `[Update: Mar. 17] Google Pixel phones still lack VoLTE & Vo-WiFi support in multiple European & Asian countries <https://piunikaweb.com/2023/03/17/google-pixel-phones-lack-volte-in-some-european-and-asian-countries/>`_
- `Enabling VoLTE & VoWifi Pixel 4 <https://xdaforums.com/t/enabling-volte-vowifi-pixel-4.4002611/>`_
- `VoLTE Patch for Pixel 4/4XL <https://github.com/hyx0329/VoLTE-Patch-for-Pixel4>`_ **已验证这个patch可以在Android 13(LineageOS 20.0)上使用**
