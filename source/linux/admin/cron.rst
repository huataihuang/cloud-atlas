.. _cron:

===============
Cron定时运行
===============


Unix/Linux系统的cron服务是一个非常重要的系统服务，提供了定时运行程序的能力。这样你可以不必人工运行程序，而让操作系统定时触发运行。

.. note::

   另外一个定时运行程序的方法是 ``at`` 服务，不过 ``at`` 是在未来某个时间运行 **一次** 程序，而 ``cron`` 则提供了周期触发运行的能力。

一些常用的 ``cron`` 使用场景：

-  定制运行日志旋转归档(logrotate)
-  定时检查日志内容触发操作(logwatch)
-  定时检查系统入侵( `Rootkit Hunter <http://rkhunter.sourceforge.net>`_ )
-  定时系统监控数据采集

``cron`` 作为定时任务配置服务，可以通过 ``crontab`` 进行交互式编辑，或者通过 ``/etc/cron.d/`` 目录下配置文件设置，此外 cron 服务还会检查 ``/var/spool/cron`` 目录下配置文件和 ``/etc/anacrontab`` 配置文件。

独立用户的 ``cron`` 文件位于 ``/var/spool/cron`` 目录下配置文件；而系统服务和应用程序通常把cron任务配置存放在 ``/etc/cron.d`` 目录。至于 ``/etc/anacrontab`` 是一个特殊配置。

使用crontab
===========

cron工具基于一个cron表格(cron table, ``crontab``)指定的命令来运行程序。每个用户，包括系统 ``root`` 用户，都可以具备一个cron文件。这个cron文件默认并不存在，但是可以通过 ``crontab -e`` 命令在 ``/var/spool/cron`` 目录下创建，每个用户一个文件。

举例， ``huatai`` 用户使用命令 ``crontab -e`` 编辑cron文件（crontab默认底层使用 ``vi`` 进行编辑），添加以下一行内容:

.. code:: bash

   * * * * * touch /tmp/test

则每秒会执行一次 ``touch`` 命令。此时检查 ``/var/spool/cron`` 目录，可以看到如下以用户名为文件名的配置文件:

.. code:: bash

   $sudo ls -lh /var/spool/cron/
   total 4.0K
   -rw------- 1 huatai staff 26 Feb 20 14:53 huatai
   -rw------- 1 root   root   0 Aug  6  2020 root

cron配置定时的案例
------------------

上述 ``crontab`` 配置的前5列是配置脚本或命令执行的周期:

::

   # Example of job definition:
   # .---------------- minute (0 - 59)
   # |  .------------- hour (0 - 23)
   # |  |  .---------- day of month (1 - 31)
   # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
   # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
   # |  |  |  |  |
   # *  *  *  *  * user-name  command to be executed

-  每天凌晨 ``01:01`` 运行一次脚本

.. code:: bash

   01 01 * * * /opt/myscript.sh

-  每隔3个月的第一天的 ``03:02`` 运行一次报告脚本

.. code:: bash

   02 03 1 1,4,7,10 * /usr/local/bin/reports.sh

-  每天上午 ``9:01`` 到下午 ``5:01`` ，每间隔1小时运行一次脚本

.. code:: bash

   01 09-17 * * * /usr/local/bin/hourlyreminder.sh

cron运行脚本
------------

通过 ``cron`` 运行的脚本有一个非常重要的要点，往往是初次使用cron的用户忽视的。 **``cron`` 执行脚本没有提供shell环境设置** ！

通常用户登陆到Linux终端时，系统会为用户配置一个 ``SHELL`` 环境，包括了一些环境变量，例如用户 ``HOME`` 目录，用户执行命令的 ``PATH`` (命令搜索路径) 变量。所以，用户可以不用输入完整的全路径就可以运行 ``/usr/local/bin`` 以及 ``/usr/bin`` 目录下的可执行程序。但是，对于 ``cron`` 来说，则不提供 ``SHELL`` 环境，所以脚本中没有配置好环境变量，往往就导致很多没有提供全路径的执行程序无法执行，导致cron没有正确运行脚本。

解决的方法有以下一些常用方法：

-  在 ``crontab -e`` 配置的cron配置文件开头就提供环境变量设置，例如

.. code:: bash

   # crontab -e
   SHELL=/bin/bash
   MAILTO=root@example.com
   PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

   # Set the hardware clock to keep it in sync with the more accurate system clock
   03 05 * * * /sbin/hwclock --systohc

   # Run my script
   0 * * * * /opt/myscript.sh

-  另一种方法是在你的shell脚本，例如 ``/opt/myscript.sh``
   开头就明确激活一次操作系统环境配置，例如

.. code:: bash

   #!/usr/bin/env bash

   . /etc/profile

   ...

限制cron访问
============

通常用户都能配置cron定时任务，但是滥用cron会导致系统资源过度消耗。为了防止这种资源滥用，系统管理员可以通过创建 ``/etc/cron.allow`` 来仅仅包含允许的用户列表，限制cron创建。

另外，系统也有一个反向配置 ``/etc/cron.deny`` 来明确拒绝某些用户使用cron。

举例，系统管理员配置了 ``/etc/cron.allow`` 配置文件，只加入一行 ``admin`` 用户。则其他系统用户，例如 ``huatai`` 用户尝试使用\ ``crontab -e``\ 时会看到以下错误提示:

::

   You (huatai) are not allowed to use this program (crontab)
   See crontab(1) for more information

系统级别配置cron
================

在 ``/etc/cron.d`` 目录下提供了系统级别运行脚本的配置。需要注意的是，如果没有指定运行用户角色，则默认使用root身份运行。所以，对于一些需要特定用户身份来运行的脚本，需要注意配置用户角色，例如，mysql备份脚本:

::

   0 1 * * * mysql /usr/local/bin/mysql_backup.sh

``cron.d`` 配置要点总结
========================

-  ``/etc/cron.d`` 目录采用了各自独立的配置文件，适合通过脚本进行管理。
-  ``/etc/cron.d`` 文件名命名必须符合 ``run-parts`` 命名方式，即使用字母，数字，下划线和中划线（不能使用点符号）
-  ``/etc/cron.d`` 中配置文件必须指定脚本运行的用户名，以便使用指定用户身份运行：

::

   0,15,30,45 * * * * root /backup.sh >/dev/null 2>&1

-  ``/etc/cron.d`` 中配置文件的文件属性必须是非可执行的且属于 ``root`` 用户（ ``-rw-r--r--`` 属主 ``root:root`` ），否则cron服务会拒绝执行该配置
-  被引用的脚本必须是可执行属性的（ ``-rwxr-xr-x`` ）
-  cron每个配置行最后必须有一个换行符号(不可见)，见下文
-  每个用户都可以配置自己的cron，所以要 :ref:`list_all_cron_jobs`

anacron
=======

``anacron`` 一个非常特别的类似 ``crond`` 相似功能的程序，但是增加了运行被跳过定时任务的执行能力，例如主机被关闭或者在某个循环周期中因故没有运行的定时任务。这个功能在一些笔记本电脑或经常关闭或休眠的电脑主机上非常有用。

当主机被关闭或重启，错过了某个或多个定时任务，则当主机再次启动时，会立即执行这些定时任务。注意，被错过的定时任务只会执行一次，不管错过了几个运行周期，都只运行一次。

周期性运行
----------

``anacron`` 程序还提供了一个非常易于理解和配置的周期定时任务方法(最小运行周期是小时)，就是将脚本存放到 ``/etc/cron.[hourly|daily|weekly|monthly]`` 目录下，就会按照不同的周期运行。非常直观简便。

-  这个窍门就在 ``/etc/cron.d/0hourly`` 配置:

.. code:: bash

   # Run the hourly jobs
   SHELL=/bin/bash
   PATH=/sbin:/bin:/usr/sbin:/usr/bin
   MAILTO=root
   01 * * * * root run-parts /etc/cron.hourly

上述cron任务在 ``/etc/cron.d/0hourly`` 配置每小时运行 ``run-parts`` 程序

-  ``run-parts`` 是一个脚本，会运行 ``/etc/cron.hourly`` 目录下的 **所有** 脚本

-  在 ``/etc/cron.hourly`` 目录下有一个 ``0anacron`` 脚本，则 ``anacron`` 程序会运行 ``/etc/anacrontab`` 配置的任务:

.. code:: bash

   # /etc/anacrontab: configuration file for anacron

   # See anacron(8) and anacrontab(5) for details.

   SHELL=/bin/sh
   PATH=/sbin:/bin:/usr/sbin:/usr/bin
   MAILTO=root
   # the maximal random delay added to the base delay of the jobs
   RANDOM_DELAY=45
   # the jobs will be started during the following hours only
   START_HOURS_RANGE=3-22

   #period in days   delay in minutes   job-identifier   command
   1   5   cron.daily      nice run-parts /etc/cron.daily
   7   25  cron.weekly     nice run-parts /etc/cron.weekly
   @monthly 45 cron.monthly        nice run-parts /etc/cron.monthly

``anacron`` 程序会每天运行 ``/etc/cron.daily`` 目录下的程序，并且每周运行一次 ``/etc/cron.weekly`` 目录下任务，以及每月运行一次 ``/etc/cron.monthly`` 目录下任务。需要注意，在每一行配置中都有一个 ``delay`` 时间，会随机延迟支持。这是为了避免系统集中执行定时任务导致过载。

需要注意 ``anacron`` 程序是一种特殊的定时任务，目的是运行在特定时间范围内，例如上面配置 ``START_HOURS_RANGE`` 是每天凌晨3点开始到晚上22点时间范围，才会开始执行定时任务。

anacron快捷方式
---------------

``/etc/anacrontab`` 配置中各有一些快捷方式，这些快捷方式取代了常规 ``crontab`` 配置中精确的5个字段时间设置。快捷方式使用 ``@`` 字符开头来表示cron快捷方式：

-  ``@reboot`` : 重启后运行一次
-  ``@yearly`` : 每年运行一次，等同 ``0 0 1 1 *``
-  ``@annually`` : 每年运行一次，等同 ``0 0 1 1 *``
-  ``@monthly`` : 每月运行一次，等同 ``0 0 1 * *``
-  ``@weekly`` : 每周运行一次，等同 ``0 0 * * 0``
-  ``@daily`` : 每天运行一次，等同 ``0 0 * * *``
-  ``@hourly`` : 每小时运行一次，等同 ``0 * * * *``

无法运行的 ``/etc/cron.d/XXXX``
================================

最近遇到一个通过脚本配置的 ``/etc/cron.d/my_cron_script`` 无法执行，非常奇特的是，同样的配置内容，之前在测试集群是完全正常的。 
::

   * * * * * root /opt/my_cron_script.sh > /dev/null 2>&1

反复检查了执行脚本的属性，手工执行都没有错误，对比了测试集群和线上集群的配置，也看不出差异。

参考 `Why doesn’t my cron.d per minute job run? <https://superuser.com/questions/664454/why-doesnt-my-cron-d-per-minute-job-run>`_ okoloBasii 的答复：

   A possible mistake here is how a single line file is created. From
   Ubuntu Documentation:

      …line has five time-and-date fields, followed by a command,
      followed by a **``newline character``** .

原因是在crontab配置中，必须确保每行命令之后有一个换行符号 ``\n`` 。这个符号是不可见字符，所以需要非常小心关注。

如何确保脚本使用创建文件行最后有一个换行符，并且能够观察到呢？

``cat`` 命令有一个 ``-A`` 参数可以实现这个功能，正确配置的命令行最后会有一个类似 ``$`` 符号显示::

   cat -A /etc/cron.d/my_cron_script

显示如下::

   * * * * * root /opt/my_cron_script.sh > /dev/null 2>&1$

参考
====

-  `How to use cron in Linux <https://opensource.com/article/17/11/how-use-cron-linux>`_
-  `What is the difference between cron.d (as in /etc/cron.d/) and crontab? <https://unix.stackexchange.com/questions/417323/what-is-the-difference-between-cron-d-as-in-etc-cron-d-and-crontab>`_
-  `CronHowto <https://help.ubuntu.com/community/CronHowto>`_
