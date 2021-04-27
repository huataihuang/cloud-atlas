.. _update_awatch_nospace:


=============================
空间不足情况升级Apple Watch
=============================

我使用的Apple Watch Series 3是非常旧款的Apple Watch，不过基本功能满足要求(主要是运动记录)。目前2021年初正在持续更新的watchOS 7系列，依然支持这款"古老"的手表。只是，这款手表的存储空间实在太小了，仅勉强够通过刷机方式安装和升级系统，无法完成OTA升级(最新的watchOS提示需要3G空闲空间才能OTA升级，而Apple Watch 3总共才4G存储空间)。

.. note::

   不过我后来发现，实际上需要仔细检查Apple Watch上存储使用详情，因为大量的空间占用可能是不注意情况下勾选了某项数据同步导致了。例如，我的Apple Watch勾选了同步音乐，整整同步了1.1G的音乐到Apple Watch。关闭同步以后，立即清理出3.2G空间，实际上够完成OTA升级。

解决Apple Watch Series 3空间不足情况下升级的方法是:

- 首先备份Apple Watch数据
- Unpair Apple Watch(恢复出厂设置，也就是抹去Apple Watch中所有数据)
- 重新配对Apple Watch(设置连接)，注意在配对时会提示是从备份中恢复还是设置一个新watch，此时一定要选择作为新watch设置，这样就不会有用户数据同步占用过多空间
- 刚完成配对的Apple Watch会有足够空间升级系统，完成升级
- 最后从先前备份的Apple Watch数据中恢复用户数据(也就是健康数据)

Apple Watch数据和健康数据支持备份到iCloud，但是默认没有启用备份到iCloud，所以需要在 ``设置 => 账号 => iCloud`` 配置中选择 ``Watch`` 和 ``健康`` 。

备份
========

当iPhone备份的时候，会自动包含已经配对的Apple Watch备份，这个过程是自动发生的，只要确保iPhone和Apple Watch相互之间接近就可以自动完成，不需要单独对Apple Watch进行备份。

iPhone备份可以选择本地备份也可以选择备份到iCloud，都会包含Apple Watch数据。这意味着设置一个新的iPhone并从备份中恢复，你的最新Apple Watch数据也会恢复。

Apple Watch备份包括：

- 应用特定数据和设置
- Home屏幕的App布局
- 时钟面板设置
- 通用系统设置
- 健康和运动数据
- 通知设置
- 播放列表和图片列表
- 时区

iCloud备份
------------

.. note::

   Apple ID是按区(国家)来隔离的，账号之间互不想通。也就是美区的Apple ID和中国区的Apple ID没有任何关联，无法共用服务(购买软件或服务)。此外，按照中国政府要求，中国区账号的iCloud数据存储在国内(云上贵州运营)。

   不过，苹果支持 ``数据备份`` 和 ``软件购买、服务订阅`` 使用不同的账号：即 ``iCloud同步`` 和 ``软件购买、服务订阅`` 可以使用不同区账号，以便实现更好的数据隔离和数据安全。 

iCloud服务是Apple生态最重要的基石：所有在同一账号下的设备能够无缝使用，都是通过iCloud服务实现的数据同步。虽然iPhone本地备份能够快速恢复数据，但是要能够随身恢复数据(包括丢失设备恢复数据)都需要iCloud备份服务。

iCloud备份包含了绝大多数重要数据(most important data on your iPhone):

- App数据
- Apple Watch备份(如果以Family Setup使用Apple Watch，则Apple Watch备份不会包含在iPhone,iPad或iPod touch备份中)
- 设备设置
- Home screen和app布局
- iMessage, text(SMS)和MMS messages
- 照片和视频
- 购买服务的历史
- 铃声
- 虚拟Voicemail密码(备份时需要SIM卡)

需要注意 邮件、健康数据、电话记录以及文件默认都没有启用iCloud备份，需要启用备份才能确保恢复(例如Apple Watch恢复健康数据记录)

Unpair和升级Apple Watch
=========================

- 确保Apple Watch和iPhone相互接近
- 在iPhone上打开 Watch 应用
- 在 ``My Watch`` （ ``我的手表`` ）面板上滚动到屏幕最上方
- 点击 ``所有 Apple Watch`` ，此时屏幕上会显示所有和这个iPhone配对过多手表
- 选择点击需要Unpair和升级的那块Apple Watch最右边的 ``i`` 符号
- 点击 ``取消配对Apple Watch`` 并确认取消配对，此时会提示输入iCloud账号对应的密码，输入密码后就开始取消配对

完成取消配对以后，Apple Watch会自动重启，重启完成后手表上会提示你配对

- 重新按照刚购买手表时配对iPhone方式再次配对:

  - 按照iPhone上Watch应用提示，使用照相机扫描Apple Watch屏幕上的配对图案进行配对
  - 注意：一定要作为新手表来配对，不要直接恢复用户备份数据，这样才有足够空间进行系统升级

.. note::

   Apple Watch升级要求配对的iPhone和Apple Watch接入同一个无线网络热点(实际上iPhone接入热点后Apple Watch会自动接入同一个热点)，Apple Watch实际上是通过无线Wifi下载安装升级奖项的，所以接入的无线必须能够访问Internet。我最初以为是iPhone下载软件包到手机中，然后通过手机蓝牙传输给Watch，但是实践发现并非如此，Watch必须能够直接访问Internet，iPhone应该只是起了管理操作作用。

- 配对完成后，在Watch应用选择 ``通用 => 软件更新`` 有最新watchOS可以升级，按照提示完成升级

参考
=======

- `Back up your Apple Watch <https://support.apple.com/en-us/HT204518>`_
- `Restore Apple Watch from a backup <https://support.apple.com/guide/watch/restore-apple-watch-from-a-backup-apdaa8cc32e8/watchos>`_
- `What does iCloud back up? <https://support.apple.com/en-us/HT207428>`_
- `If you don’t have enough space to update your Apple Watch <https://support.apple.com/en-us/HT211283>`_
