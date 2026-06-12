.. _migrate_phpmyadmin:

========================
迁移phpMyAdmin
========================

将一台主机的phpMyAdmin迁移到另外一台主机需要完成以下3个步骤:

- 在旧的phpMyAdmin主机上执行以下命令，将数据库的 ``phpmyadmin`` 库备份出来: 这个数据库记录了网页偏好，SQL历史，书签等:

.. literalinclude:: migrate_phpmyadmin/mysqldump
   :caption: 备份 ``phpmyadmin`` 库

- 在新服务器上部署 :ref:`install_phpmyadmin`

- 将旧主机上的备份文件，导入新主机的数据库进行覆盖，这样就能找回所有历史配置:

.. literalinclude:: migrate_phpmyadmin/import
   :caption: 导入数据库

- 最后，将原主机的核心配置复制到新主机，该配置文件位于 ``/etc/phpmyadmin/`` 目录下，需要复制 ``config.inc.php``
