.. _pixel_volte:

==============
Pixel VoLTE
==============

入手 :ref:`pixel` 手机，经过一周的调教，已经如丝般滑顺(前提是摈弃所有国产软件)，并且root之后的Android提供了超越iOS的便利之处。

然而，中国移动运营商摒弃2G/3G技术导致很多地方如果没有VoLTE的4G语音技术加持，几乎无法正常通话。这就遇到一个尴尬的难题：自从2010年，Google被迫退出中国市场之后，已经没有正式渠道能够获得官方的产品和技术支持。同样Pixel以及后几代产品，在中国市场上只有水货，并且没有得到运营商VoLTE的数据配置支持。这是中国消费者的悲哀...

硬件支持
=========

Pixel 和 Pixel XL硬件上是支持VoLTE技术的(2016底年印度市场Pixel已经通过更新Android Nougat 7.1.1 OTA支持VoLTE)，并且当前Google Android系统对于支持VoLTE技术是非常友好的，只要运营商提供了配置，就可以直接开启。然而，不幸的是在中国市场上的运营商都没有提供配置。

通过电话拨号: ``*#*#4636#*#*`` 可以进入 ``Testing`` 设置，然后再点 ``Phone Info`` 其中就可以看到 ``VoLTE Provisioned`` 是灰色不可设置项。

可以通过 `Magisk voenabler <https://github.com/edgd1er/voenabler>`_ (XDA原帖见 `VoLTE & VoWiFi Enabler (2018-09-20) <https://forum.xda-developers.com/apps/magisk/module-v4-volte-enabler-t3649613>`_ ) 激活VoLTE功能，原理就是修改 `vender/build.prop` 添加激活volte的配置::

   # Debug Options
   persist.dbg.ims_volte_enable=1 
   persist.dbg.volte_avail_ovr=1 
   persist.dbg.vt_avail_ovr=1
   persist.dbg.wfc_avail_ovr=1

   # Radio Options
   persist.radio.rat_on=combine
   persist.radio.data_ltd_sys_ind=1
   persist.radio.data_con_rprt=1
   persist.radio.calls.on.ims=1

从 `GitHub Magisk-Module-Repo <https://github.com/Magisk-Modules-Repo>`_ 下载... 目前已经没有直接下载的voenabler模块，不过原作者的 `GitHub Toucan-Sam VoEnabler <https://github.com/Toucan-Sam/VoEnabler>`_ 有很多fork出来的项目，例如 `edgd1er / voenabler <https://github.com/edgd1er/voenabler/releases>`_ 提供直接直接可用适合最新Magisk's module template 20.x的版本，可以直接下载：`voenabler-v1.6.zip 
<https://github.com/edgd1er/voenabler/releases/download/v1.6/voenabler-v1.6.zip>`_

- 将 ``voenabler-v1.6.zip`` 推送到手机::

   adb push voenabler-v1.6.zip /sdcard/

- 启动Magisk程序，然后选择菜单 ``Modules`` ，并点击屏幕上 ``+`` 按钮，并通过文件管理器找到 ``voenabler-v1.6.zip`` 进行安装

- 安装以后按照提示重启手机，重启以后在 ``Settings => Network & Internet => Mobile network`` 中查看，就可以看到增加了一项 ``VoLTE`` 选项并且已经激活：

.. figure:: ../../_static/android/hack/volte_pixel.png
   :scale: 75

- 验证VoLTE功能：

启用LTE 4G上网浏览网页，同时拨打10086听语音，如果语音同时还能够上网，则表示VoLTE工作正常。

.. note::

   很不幸，虽然此时激活了VoLTE开关，但是实际上该功能还是无效的，电话同时并不能上网。这是因为此时手机中缺少中国地区运营商参数配置(因为Google压根就没有和中国三大运营商合作 - 中国政府不会允许的)。解决方法是从其他国产手机(如小米)提取国内运营商的VoLTE配置，制作成Magisk模块加载。

运营商配置Magisk模块(失败)
============================

参考宁静的雨 `开通VoLTE后发现Pixel手机不支持？装上这个Magisk模块就好了 <https://sspai.com/post/53949>`_ 下载其提供的 VoLTE配置包 也通过Magisk加入。这个配置软件包也可以从 `magisk-pixel2-china-volte <https://github.com/muink/magisk-pixel2-china-volte>`_ 获得。

.. note::

   上述方法是针对Pixel 2/2XL，我在Pixel XL上验证没有效果。原因是每款产品的配置文件目录实际是不同的，例如 Pixel 2 和 Pixel 2XL的运营商配置目录不同，相应的Pixel一代的运营商配置也有差异。

在 ``/firmware/radio/modem_pr/mcfg/configs/mcfg_sw/generic/common/wildcard/wildcard`` 文件中有包含中国移动波段::

      <!-- China LTE Bands: 1, 3, 5, 7, 8, 38, 39, 40, 41  -->
      <rf_band_list name="china_bands">
         <gw_bands base="hardware"/>
         <lte_bands base="none">
            <include> 0 2 4 6 7 37 38 39 40 </include>
         </lte_bands>
         <tds_bands base="hardware"/>
      </rf_band_list>

在安装了上述magisk的module之后 ``/sbin/.magisk/mirror/data`` 目录下可以找到 ``mcfg_sw`` 配置目录::

   ./misc/radio/modem_config/mcfg_sw
   ./misc/modem_config/mcfg_sw

其中 ``/sbin/.magisk/mirror/data/misc/radio/modem_config/mcfg_sw/generic`` 目录下包含了 ``china`` 目录 以及 ``common`` 目录。

更进一步可以看到 ``/sbin/.magisk/mirror/data/misc/radio/modem_config/mcfg_sw/generic/common/wildcard/wildcard/mcfg_sw.mbn`` 配置文件

手工配置VoLTE
================

在 `Pixel2(2XL) Anroid 8+/9.0 破解电信4G网络+开启VOLTE通话 <http://bbs.gfan.com/android-9536094-1-1.html>`_ 提供了完整的手工设置方法(在2楼是中国移动配置方法)，虽然是Pixel 2/2XL，不过可以借鉴尝试。

* 下载 `pixel2/2xl配置调整包 <https://pan.baidu.com/s/1Fw01aG0ZqeDOOya57zIDYA>`_ 下载后解压缩，其中有一个目录 ``modem_pr/mcfg/configs/mcfg_sw/generic/china`` 子目录，这个子目录完整复制到下一步所说的手机内部的对应目录：

  * Pixel 2: ``vendor/rfs/msm/mpss/readonly/mbn/mcfg/configs/mcfgsw/generic/``
  * Pixel 2XL: ``vendor/mbn/mcfg/configs/mcfg_sw/generic``

由于我是Pixel XL，搜索目录 ``mcfg_sw`` 可以看到 ::

   ./data/misc/radio/modem_config/mcfg_sw
   ./data/misc/modem_config/mcfg_sw
   ./firmware/radio/modem_pr/mcfg/configs/mcfg_sw
   ./sbin/.magisk/mirror/data/misc/radio/modem_config/mcfg_sw
   ./sbin/.magisk/mirror/data/misc/modem_config/mcfg_sw

其中最后2条是之前安装过Magisk的模块保留的？所以可能需要存放运营商配置的是前3个目录。分别检查这3个目录下的 ``generic`` 子目录，其中2个目录包含了各地运营商的配置信息::

   /data/misc/radio/modem_config/mcfg_sw/generic
   /firmware/radio/modem_pr/mcfg/configs/mcfg_sw/generic

但是，其中后一个目录 ``/firmware/radio/modem_pr/mcfg/configs/mcfg_sw/generic`` 是系统目录，只读无法写入。

参考 `pixel XL VOLTE求助 <http://bbs.gfan.com/android-9538649-1-1.html>`_ 有人提到 pixel的目录应该是这个 ``/firmware/radio/modem_pr/mcfg/configs/mcfg_sw/generic/common`` 

但是如何写入这个目录是一个疑问？


所以推断应该将中国运营商的配置信息存放到 ``/data/misc/radio/modem_config/mcfg_sw/generic`` 目录下，在没有添加中国运营商配置信息之前，该目录下有5个子目录，分别代表欧洲、北美、亚太等5个地区::

   apac aus common eu na

.. note::

   如果使用Pixel 2/2XL则：

   * Pixel 2目录 ``vendor/rfs/msm/mpss/readonly/mbn/mcfg/configs/mcfgsw/generic/``
   * Pixel 2XL目录 ``vendor/mbn/mcfg/configs/mcfg_sw/generic``

我们需要把解压缩的文件中 ``china`` 文件夹复制进去，成为并列的第6个文件夹。不过直接用 ``adb push china <目标目录>`` 都提示 ``Permission denied``

所以先使用 ``adb push china /sdcard`` 将文件传输到手机内的存储目录，然后再在手机内部执行::

   cd /data/misc/radio/modem_config/mcfg_sw/generic
   cp -R /sdcard/china ./

.. note::

   检查发现实际上安装了 Magisk 的 ``enable_volte_pixel2_china.zip`` ，系统会挂载2个目录::

      /sbin/.magisk/block/vendor 295M  249M   46M  85% /sbin/.magisk/mirror/vendor
      /sbin/.magisk/block/data   112G   11G  101G  11% /sbin/.magisk/mirror/data

   这样应该是一个overlay的解决方案，如果后续改成Magisk方式，可以尝试执行如下方式overlay。

* 上述步骤完成以后，就会发现开启了工程模式查看 phone info 中，原先灰色的 ``VoLTE Provisioned`` 虽然还是灰色，但是灰色部分却显示为激活状态(虽然看上去不能调整)。这比之前始终灰色且关闭状态前进了一步。

修改 build.prop
================

Andorid 6.0之后不能直接修改只读的 ``/system`` 分区，所以我们需要使用 ``systemless`` 方式的 :ref:`magisk` 来overlay修改系统配置。

.. note::

   我暂时还没有找到修订 build.prop 的方法，但是我觉得magisk通过overlay可以修订。此外，既然 一加3T 和 小米 5s 是和Pixel同样的CPU，应该可以借鉴他们的image来解决Pixel的VoLTE。我准备下载这两个国产手机的rom来找寻VoLTE配置。

* (未找到该文件，没有执行)在gneric同级目录下有一个 ``oem-sw.txt`` 文件，在最后添加如下内容::

   mcfg_sw/generic/china/cmcc/commerci/volte_op/mcfg_sw.mbn

* 在 ``build.prop`` 文件中添加以下内容激活volte代码

常规是需要修改 ``/system/build.prop`` 配置的，但是在android 10中，默认不能读写根文件系统。并且以前采用的命令::

   mount -o remount,rw /

会提示报错::

   '/dev/root' is read-only

解决方法是参考 `Android O, failed to mount /system, /dev/block/dm-0 is read only <https://android.stackexchange.com/questions/186630/android-o-failed-to-mount-system-dev-block-dm-0-is-read-only>`_ 执行::

   adb root
   adb disable-verity
   adb reboot
   adb remount
   adb shell
   mount -o rw,remount /system

.. note::

   需要注意，上述 ``adb disable-verity`` 只能在 ``userdebug`` builds使用，默认通过 ``cat /system/build.prop | grep build.type`` 可以看到::

      ro.system.build.type=user
      ro.build.type=user

   这种user模式下，执行 ``adb disable-verity`` 会报错::

      disable-verity only works for userdebug builds
      verity cannot be disabled/enabled - USER build

magisk提供了覆盖方法，在 ``/sbin/.magisk/`` 目录下搜索可以看到有如下配置::

   ./mirror/vendor/odm/etc/build.prop
   ./mirror/vendor/build.prop
   ./mirror/system_root/system/product/build.prop
   ./mirror/system_root/system/build.prop

但是也不能修改(因为是软链接) ``./mirror/system_root/system/build.prop`` ::

   ro.mtk_ims_support=1                                
   ro.mtk_volte_support=1
   persist.mtk.volte.enable=1
   persist.dbg.volte_avail_ovr=1

   # 可能只要添加以上4行就可以
   persist.dbg.ims_volte_enable=1
   persist.dbg.volte_avail_ovr=1
   persist.dbg.vt_avail_ovr=1
   persist.dbg.wfc_avail_ovr=1
   persist.radio.rat_on=combine
   persist.radio.data_ltd_sys_ind=1
   persist.radio.data_con_rprt=1
   persist.radio.calls.on.ims=1

.. warning::

   非常失败，实际上没有搞定Android 10环境下激活Pixel的VoLTE，实在太折腾了。Pixel全系列不能在墙内使用VoLTE真是让人折磨死，即使后续各个版本，能够通过破解来激活VoLTE，但依然没有保障，任何升级都可能破坏激活。

   看来，Pixel注定只能是移动终端兼备机角色了...

参考
======

- `Does the Google Pixel 1 support VoLTE? <https://www.quora.com/Does-the-Google-Pixel-1-support-VoLTE>`_
- `How to enable VoLTE on Pixel? <https://forum.xda-developers.com/pixel-xl/help/how-to-enable-volte-pixel-t3685855>`_
- `Enable China Telecom LTE by modifying modem partitions <https://forum.xda-developers.com/pixel-xl/how-to/guide-enable-china-telecom-lte-t3782538>`_ - 这个帖子是从一加手机中复制出运营商配置信息
- `Pixel2(2XL) Anroid 8+/9.0 破解电信4G网络+开启VOLTE通话 <http://bbs.gfan.com/android-9536094-1-1.html>`_ - 这个帖子是指导如何手工一步步启用VoLTE的方法，对于直接使用Magisk包不生效的时候，可以尝试
- `Magisk-Module-Repo/chinese_sim_supporter <https://github.com/Magisk-Modules-Repo/chinese_sim_supporter>`_ 支持Pixel 3在中国运营商环境(中国移动/联通/电信)开启VoLTE

