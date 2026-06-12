.. _debian12_install_mariadb:

===============================
在Debian 12中安装MariaDB
===============================

自从Oracle公司收购了Sun公司并获得了MySQL，开源社区已经重新fork出了采用纯粹GPL协议并承诺永远开源的MariaDB，并且由MySQL创始人（Michael "Monty" Widenius）管理开发。这意味着所有高级功能(包括高效的线程池、强大的各种存储引擎)在MariaDB中是完全免费且开源的。

事实上，自 Debian 9 开始，Debian 官方开源社区就已经把 MySQL 从默认软件仓库中彻底移除，并用 MariaDB 取而代之。也就是说，即使你使用 ``sudo apt install mysql-server`` 安装的其实还是MariaDB。

.. note::

   虽然 MySQL 和 MariaDB基本SQL语法(CRUD,索引,触发器)完全一致，但是两个数据库还是有不同的分支差别:

   - MySQL 8.0/8.4 引入了一些独特的 JSON 增强函数、窗口函数（Window Functions）以及新的默认认证插件（caching_sha2_password）
   - MariaDB 则推出了自己特有的临时表（Temporal Tables）和更灵活的存储引擎（如 ColumnStore 列式存储、MyRocks 引擎）

安装
=========

- 安装:

.. literalinclude:: debian12_install_mariadb/install
   :caption: 在debian中安装MariaDB

``mariadb-server`` 提供了数据库服务， ``mariadb-client`` 则提供 ``mariadb`` shell用于本地管理，远程登录，dump等管理。

.. note::

   这里在一台主机上安装了服务和客户端，实际生产环境，两者可以完全独立分别安装。服务器上仅需要安装 ``mariadb-server`` ，可以通过 ``mariadb-client`` 远程管理。

- 检查安装版本:

.. literalinclude:: debian12_install_mariadb/version
   :caption: 检查MariaDB安装版本

可以看到当前系统中安装的版本(10.11.14):

.. literalinclude:: debian12_install_mariadb/version_output
   :caption: 检查MariaDB安装版本

注意，MariaDB的版本是10.11.14，在输出行中看到的 ``Ver 15.1`` 实际上是MariaDB从MySQL 5.5分支fork出时，为了避免和MySQL库文件命名冲图，将客户端协议主版本号强行定义为 ``15`` ，这个数字一直以来都没有变过。

.. literalinclude:: debian12_install_mariadb/mariadb-admin_version
   :caption: 检查MariaDB安装版本(mariadb-admin方式)
   :emphasize-lines: 5

- 安装完成后，默认会启动并激活mariadb服务，可以通过以下命令验证:

.. literalinclude:: debian12_install_mariadb/verify
   :caption: 验证mariadb的启动和激活

输出可以看到

.. literalinclude:: debian12_install_mariadb/verify_output
   :caption: 验证mariadb的启动和激活

如果没有激活或启动，则执行以下命令:

.. literalinclude:: debian12_install_mariadb/enable
   :caption: 激活mariadb

配置
========

- 执行以下交互命令来移出默认的不安全设置并刷新:

.. literalinclude:: debian12_install_mariadb/secure
   :caption: 安全设置交互

这里有一些交互回答，通常按照默认回答就可以:

.. literalinclude:: debian12_install_mariadb/secure_output
   :caption: 安全设置交互
   :emphasize-lines: 16,24,38,44,51,60

- ``Enter current password for root (enter for none):`` 由于用 apt 刚装好，默认没有任何密码。直接按回车（Enter） 即可。
- ``Switch to unix_socket authentication [Y/n]`` 强烈推荐输入 **y** 确认: 

  - ``unix_socket`` （本地套接字认证） 是 MariaDB/MySQL 在 Linux 下的一项高级安全特性。如果你已经是 Linux 系统里的 ``root`` 用户（比如你通过 ``sudo -i``  或在 :ref:`incus` 里本来就是 root），当输入 mariadb 时，数据库会直接信任你的 Linux 系统身份，免密码直接让你登录。
  - **优点** ： 极大地方便了系统运维自动化脚本（比如备份脚本），不再需要把数据库明文密码写在脚本里面，只要保护好Linux的root权限即可，非常安全
  - **缺点** : 无法在远程使用这种免密方式，远程依然必须用密码

- ``Change the root password? [Y/n]`` : 设置数据库传统的明文密码，该密码可以在 :ref:`phpmyadmin` 这样的管理平台中使用，也可以通过网络访问数据库

- ``Remove anonymous users? [Y/n]`` : 输入 ``y`` 删除掉默认安装的匿名账号(方便新手测试)

- ``Disallow root login remotely? [Y/n]`` : 出于安全建议回答 ``y`` 避免远程root用户访问，对于本地root用户访问不受限，通常 :ref:`phpmyadmin` 本地安装也没有影响

- ``Remove test database and access to it? [Y/n]`` : 建议回答 ``y`` 删除掉默认创建的 ``test`` 数据库

- ``Reload privilege tables now? [Y/n]`` : 回答 ``y`` 立即刷新权限表

参考
========

- `How to Install MariaDB on Debian 13, 12 and 11 <https://linuxcapable.com/how-to-install-mariadb-debian-linux/>`_
