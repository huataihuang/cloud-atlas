.. _transfer_icloud_photos:

=======================
iCloud帐号间照片转换
=======================

如果你希望 :ref:`open_your_mind` ，通过Apple美区帐号订阅 :ref:`apple_one` ，应该会遇到如何将原先中国区的相片导入到新的美区帐号的困扰。虽然也可以先把所有的照片先导出到文件目录中(也就是独立的照片和视频)，但是这种操作非常麻烦和低效，并且需要占用两倍磁盘空间。

实际上，苹果提供了直接的帐号间照片转换功能，原理就是退出旧帐号时在本地保留上旧帐号的Photos图片库不删除(注意要下载原始文件)，然后使用新(美区)帐号登录，并选择使用 ``icloud`` 图片库。此时就会自动把本地Photos图片库和iCloud进行同步，有就是把上一个旧帐号中的所有图片都复制到现今iCloud帐号中。完全同步以后，旧帐号的照片就会迁移到新帐号，也就可以无缝切换了。

.. note::

   微信的数据迁移建议采用 `如何迁移/备份微信聊天记录? <https://kf.qq.com/touch/wxappfaq/180122ua6NB7180122zI3AZR.html>`_ ，通过另一个手机临时备份微信记录。等苹果帐号切换以后，再恢复回来。

- 在操作前，首先完整备份一次Photos图片库 - 我是采用将照片 ``Exports`` 出来，然后复制到移动硬盘中备份
- 按照苹果技术支持提供的方法，可以使用iOS设备来完成这个帐号照片转换。不过，我实际上是采用macOS来完成的，也就是使用苹果笔记本电脑，因为苹果macOS支持多用户使用，我可以用不同的用户帐号登录电脑操作系统，来完成备份、数据腾挪
- 先使用旧iCloud帐号登录，完成所有照片本地下载同步(注意：一定要选择 ``Preferences... >> iCloud >> iCloud Photos >> Download Originals to this Mac`` (只有选择下载原始文件才能确保迁移到新帐号照片格式信息完全一致)
- 完成旧帐号照片同步以后，退出旧iCloud帐号，此时本地图片库保留不删除
- 登录新的美区帐号，再次打开Photos应用，然后选择 ``Preferences... >> iCloud >> iCloud Photos`` ，勾选了 ``iCloud Photos`` 之后，本地照片库的文件就会同步上传到新帐号iCloud云盘中。

最后，你的新帐号的iCloud图片会和旧帐号完全一致，完成迁移。

参考
========

- `Transferring all Photos from one iCloud account to another <https://discussions.apple.com/thread/250402186>`_
