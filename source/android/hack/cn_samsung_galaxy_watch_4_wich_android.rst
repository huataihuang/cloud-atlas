.. _cn_samsung_galaxy_watch_4_wich_android:

============================================
原生Android适配使用国行三星Galaxy Watch 4
============================================

.. note::

   这是一个非常折腾的过程，真的非常折腾，我大约花了两天多反复尝试才完成 :ref:`pixel_4` 适配连接 :ref:`samsung_galaxy_watch_4_classic_lte`

.. note::

   我最初在自己 :ref:`build_lineageos_20_pixel_4` 上适配Galaxy Watch 4，当时没有经验，没有使用特定旧版Galaxy Wearable来适配，导致反复失败。我误以为是LineageOS默认精简系统可能缺乏某些框架组件导致三星的wearable软件无法正常运行。所以当时我又尝试重新刷机 :ref:`android_13_pixel_4` ，又多折腾一天。后来才明白原来是三星最新版本对国行校验的"地狱模式"导致的问题...

所谓 "国行"
=============

我在选购 :ref:`samsung_galaxy_watch_4` 时，最初是想购买三星Galaxy Watch 4美版，因为二手价格相对低廉。不过，一番折腾和偶然发现，最后"阴差阳错"购买了国行版本 :ref:`samsung_galaxy_watch_4_classic_lte` ``SM-R8950`` 。折腾就此拉开序幕...

简要说明:

- 由于 "特殊国情" ，三星的国行智能手表会检测屏蔽所有使用Google Play服务和Google Play Store的手机，也就是从底层屏蔽所有非国产的手机(恶心!!!)
- 如果你使用海外购买的手机或者刷了Google原生Android系统，或者 LineageOS 这样第三方ROM，只要手机中使用了Google Play服务和Store，都需要采用本文方法来绕开三星Wearable软件的检测

  - 很不幸，目前找到的方法只对2022年7月之前的Samsung Wearable软件有效，在使用了Google服务的原生Android系统上使用最新的Samsung Wearable将无法配对国行Galaxy Watch 4

- 对于普通用户，如果不想折腾，那么只能国行安卓手机配国行三星智能手表；如果美版Android手机(例如Pixel)则建议使用美版Samsung Galaxy Watch

关于 "美版"
============

美版的三星Galaxy Watch 4虽然容易适配美版三星Galaxy手机，但是对于美版Watch 4 LTE版本，存在一个(反向)无法直接使用国内移动运营商网络的问题。 `美版三星galaxy watch LTE 版本（带u型号，如sm-r865u，4、5、6代）解锁基带频段限制以实现非美国区域移动网络可用 <https://post.cplus8.com/d/647>`_ 楼主 "傑克•特裡•斯科鋪" 提供了一个很好的解决方法:

- 三星官网上的链接性能信息显示 ``sm-875u`` (美版Galaxy Watch4 44mm) 和 ``sm-b65u`` (美版Galaxy Watch4 40mm) 的 LTE BAND Support 覆盖了B5频率段(850MHz)是得到国内三家移动运营商支持的，此外国际版本(f后缀)还支持联通电信所使用的B1和B3
- 三星的Galaxy Watch提供了 ``secret code`` 可以激活 ``service mode`` ，能够启用一些被屏蔽的功能参数:  ``#2263# *CPLUS!`` 可能可以打开Network Setting，其中有一个菜单 ``Band Disable`` 有一些频段被关闭了，所以将所有频段打开就可以支持国内移动运营商网络
- 此外 ``Band Selection`` 可以锁定运营商的网络频段，例如中国联通使用B3
- 这篇文章还推荐添加国外的esim卡来实现移动网络(思路打开):

  - Eskimo的免费1.5G有效期一年的esim
  - 澳门电讯的esim: `CTM 5G Chill Prepaid card-澳门电讯5G快卡小测 <https://post.cplus8.com/d/587>`_
  - 三星Galaxy Watch 4有两个 esim 槽位，可以用一个esim来接收验证码(我突然想到 :ref:`us_apple_id_paypal` 一直难以解决的海外手机号码接收验证码才能开启PayPal国际支付 )

解决方案(综合)
=================

我的实践是参考 `非国行的Android不能使用国行的Watch4？不指望三星，自力更生完美解决 <https://blog.xuegaogg.com/posts/1931/>`_ 完成的，不过也因为时过境迁又有了新的异常需要克服:

- google play store提供的三星wearable已经不能用于国行Galaxy Watch 4了，虽然我关闭了Google Play Service 和 Google Play Store，但是依然无法配对Watch: 看上去配对成功，但是Next步骤之后会莫名程序退出。偶然看到google play store有人提到要使用2022年7月前的版本，才尝试成功。

- 在 `APKMirror <https://www.apkmirror.com/>`_  网站上能够找到旧版本samsung wearable软件，我使用 `2.2.48.22033061 <https://www.apkmirror.com/apk/samsung-electronics-co-ltd/samsung-gear/samsung-gear-2-2-48-22033061-release/galaxy-wearable-samsung-gear-2-2-48-22033061-android-apk-download/download/?key=d201d9a185e1e57899b1fcd067c0ea2f17ef4551>`_ 成功

操作步骤简述
--------------

- 系统管理关闭 Google Play service 和 Play store (按照网友建议，这步是解决 ``Samsung wareables`` 运行的关键)

.. note::

   一定不要使用Google Play Store上最新版本的 "三星健康穿戴" 程序(Samsung Wearable)，这个程序启动时检测到国行版本Galaxy Watch会提示和手机版本不兼容，而且即使如上关闭了 Google Play service 和 Play store ，看似能够蓝牙配对，但是在后续步骤中会异常退出，导致整个设置过程前功尽弃。

- 从 `APKMirror <https://www.apkmirror.com/>`_ 搜索下载2022年7月以前的Samsung Wearable软件包，例如 `2.2.48.22033061 <https://www.apkmirror.com/apk/samsung-electronics-co-ltd/samsung-gear/samsung-gear-2-2-48-22033061-release/galaxy-wearable-samsung-gear-2-2-48-22033061-android-apk-download/download/?key=d201d9a185e1e57899b1fcd067c0ea2f17ef4551>`_ 我已经验证成功。此时手机中不需要安装其他程序，即不需要安装Wear OS，也不需要安装Samsung Watch4
  Manager(插件)，这两个程序会在配对后自动安装，而且是从三星自家的网站直接下载(无需翻墙)

  - **海外手机初次和配对国行三星Galaxy Watch 4必须使用旧版Samsung Wearable软件包** 否则无法绕过软件对墙内用户的限制(悲伤)
  - 当手机和手表上同时出现开始配对的数字，先点一下手机上的确认配对，过一秒钟，马上点一下手表上的确认按钮(重要，否则会配对超时失败)，此时手机上马上会显示配对成功，就会开始进行读取手表信息的读条
  - 我的经验是蓝牙配对要使用 Samsung Wearable 完成，而不能使用Google WearOS(也提供了蓝牙配对，两者重复操作会失败)

- 由于已经关闭了 Google Play service 和 Play store，所以就会顺利躲过 Samsung Wearable 对墙内用户的手机强制检测(应该是国行手表固件触发的检测)，此时就会进入蓝牙

  - 手机和手表上同时出现开始配对的数字，先点击手机上的配对确认，然后再看手表上数字下面是否有确认按钮，如果有的话也需要点一下，如果没有就手表会自动确认(这个似乎和手机上安装的 Samsung Wearable 软件版本有关)
  - 蓝牙配对后，Samsung Wearable会自动安装Google Wear OS和Watch4 Manager插件，不过，这个下载安装是直接从三星服务器上获得，不是Google Play Store，所以无需翻墙

- 我反复安装配对了两三遍才成功，原因是:

  - 最初 三星wearable 会安装Google Wear OS，然后Wear OS 会自己发起一次蓝牙匹配，实际上蓝牙匹配要在wearable中完成，Wear OS实际匹配和同步数据会卡死。然后我关掉wear os整个过程就失败了
  - 三星wearable 还会自己安装 Watch4 Manager，我发现可能要等 Wear OS 和 Watch4 Manager都下载安装好，然后再次启动三星wearable进行重新配对，就会跳过软件安装，快速进入数据同步就很神奇地成功了

- 总之，非常折腾，需要耐性反复尝试。因为国情特殊导致一系列技术消耗，浪费了很多人的时间和精力，也损害了三星的产品声誉。

.. note::

   `三星watch6 flyme(非三星安卓)系统折腾记 <https://www.aprdec.top/index.php/archives/200>`_ 这位 "孟夏十二" 网友提供了全套   


其他方案
=============

Watch刷国际版本
----------------

另一种思路是把手表系统刷成国际版本:

- `Galaxy Watch 4/5 国行转外版固件资料 <https://www.bilibili.com/read/cv21804247/>`_
- `Galaxy Watch 4/5 固件刷写指南 (2nd Version) <https://www.bilibili.com/read/cv23847143/>`_ 利用 `Bifrost - Samsung Firmware Downloader <https://github.com/zacharee/SamloaderKotlin>`_ 下载对于型号的固件包（CSC举例：国行CHC，美版XAA）。输入信息后先Check for Update，然后Download。

不过刷机以后会丢失国行提供的交通卡和门禁卡功能，另外刷机没有保修。此外，我最大担心是刷机以后，国行的LTE功能可能就无法使用了，因为对于Android系统来说，没有运营商的profile，是无法正常使用LTE功能的。

所有，我力求保留国行系统的条件下，实现原生Android的配对和使用。

定制ROM连接Watch解决方法(参考)
--------------------------------

`Magisk Module - Use Galaxy Wearable App With Any Custom ROM <https://xdaforums.com/t/magisk-module-use-galaxy-wearable-app-with-any-custom-rom.4459715/>`_ 提供了一种在三星手机上修改官方ROM之后，会导致无法连接三星Watch的解决方法。不过，这个解决方法只针对三星OneUI操作系统，我实践发现当使用 :ref:`magisk` 安装 `KnoxPatch <https://github.com/BlackMesa123/KnoxPatch>`_ 会失败，提示该模块只支持三星OneUI。

另外 `SHM-MOD <https://github.com/ITDev93/SHM-MOD>`_ 在Google doc `Watch4 Pairing issues on Galaxy Wearbles <https://drive.google.com/drive/folders/138thPYPMbZIp2Us0Unx_h-SqJQEDxZ-0>`_ 我验证下来对国行Galaxy Watch 4没有效果。看来国外用户遇到的问题和我们国内国行完全不同，国内国行是三星强制限制只能使用国内阉割版安卓系统导致的，估计老外都没有这个问题。国外主要遇到的问题是 ``rooted`` 之后的三星手机，由于 ``Knox security``
安全特性导致的连接障碍，此时可以使用这个方案来fix。

参考
======

- `非国行的Android不能使用国行的Watch4？不指望三星，自力更生完美解决 <https://blog.xuegaogg.com/posts/1931/>`_
- `给国行 Galaxy Watch 4 应用生态加了一片瓦（YaoYao 跳绳） <https://v2ex.com/t/821295>`_
- `抢先 Pixel Watch，三星 Galaxy Watch 4 手表获得基于 Wear OS 4 的 One UI 5 Watch 更新 <https://www.ithome.com/0/717/060.htm>`_ 新闻而已，不过可以知道Galaxy Watch 4会得到更新
- `Galaxy Watch4：难道只是星粉的自我狂欢？ <https://sspai.com/post/70741>`_ 这篇评测可以了解Galaxy Watch 4的优缺点
- `三星watch6 flyme(非三星安卓)系统折腾记 <https://www.aprdec.top/index.php/archives/200>`_
