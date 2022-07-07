.. _date_caculate:

date计算时间差
==============

- 简单输出UNIX秒:

.. code:: bash

   date +%s

在shell中将时间转换成1970年开始的秒，则可以进行计算，\ ``date -d +%s``\ 可以输出当前时间的UNIX秒。

-  脚本案例：

.. code:: bash

   CURTIME=`date +"%Y-%m-%d %H:%M:%S"` #当前的系统时间 2009-05-04 14:34:00
   LASTLINE=$(ls -lt * "$v_DIRNAME"| line | awk '{print $6,$7,$8}')    #获取文件的最后时间 2009-10-04 14:30:00 
   echo "lasttime "$LASTLINE  
   echo "Systime "$CURTIME
   Sys_data=`date -d  "$CURTIME" +%s`    #把当前时间转化为Linux时间
   In_data=`date -d  "$LASTLINE" +%s`
   interval=`expr $Sys_data - $In_data`  #计算2个时间的差
   echo $In_data
   echo $Sys_data
   echo $interval

如果要计算日期差异，可以使用 ``bc`` 命令计算：

.. code:: bash

   echo "$interval / 3600 /24" | bc

参考 `Convert date time string to epoch in
Bash <https://stackoverflow.com/questions/10990949/convert-date-time-string-to-epoch-in-bash/10990961>`__
和 `How to convert DATE to UNIX TIMESTAMP in shell script on
MacOS <https://stackoverflow.com/questions/3817750/how-to-convert-date-to-unix-timestamp-in-shell-script-on-macos>`__
需要注意不同平台转换格式有区别：

-  Linux平台希望输入的日期格式是 US 或 ISO860 格式，类似 ``mm/dd/yyyy``
   或者 ``yyyy-mm-dd`` ，素以你可以使用
   ``date --date='06/12/2012 07:21:22' +"%s"``
-  macOS平台采用的格式是
   ``date -j -f "%a %b %d %T %Z %Y" "Tue Sep 28 19:35:15 EDT 2010" "+%s"``
   或者

.. code:: bash

   date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"

需要注意macOS需要提供格式参数 ``-f`` 否则会报错，举例:

.. code:: bash

   date -j -f "%Y-%m-%d" "2010-10-02" "+%s"

则输出 ``1286009053``

或者:

.. code:: bash

   date -j -f "%m/%d/%Y" '07/06/2021' +"%s"

输出 ``1625561120``

很不幸，macOS的转换方法和Linux不能兼容（linux不支持 ``-j``
并且一定要使用 ``-d``\ ），所以如果要脚本通用，需要判断平台，否则报错

--------------

时间差计算可以使用上述 ``expr $Sys_data - $In_data``
，也可以使用单括号运算符\ ``$()``\ ：

.. code:: bash

   interval=$($Sys_data - $In_data)

获取当前时间的几分钟或几小时前时间
==================================

-  10分钟前

.. code:: bash

   $date -d "10 minute ago" +"%Y-%m-%d %H:%M"
   2017-10-12 17:50

   $date -d "-10 minute" +"%Y-%m-%d %H:%M"
   2017-10-12 17:50

上述 ``-d`` 参数也可以使用 ``--date`` 方式，类似要获取1分钟前时间

.. code:: bash

   date --date="-1 minutes" '+%Y-%m-%d %T'

或者一秒钟前时间:

.. code:: bash

   date --date="+1 seconds" '+%Y-%m-%d %T'

-  一小时前

.. code:: bash

   date --date="-1 hours" +"%Y-%m-%d %H:%M"

-  一天前

.. code:: bash

   date --date="-1 days" +"%Y-%m-%d %H:%M"

..

   ``-d``\ 和\ ``--date``\ 等同

日期格式的转换
==============

在前面的两个案例中，\ ``date``\ 命令有一个很重要和有用的参数\ ``-d``\ ，这个参数的含义是让\ ``date``\ 命令不是从当前时钟读取，而是从指定变量读取。正是有了这个变量，上述案例才能从各个变量中获取值，然后利用\ ``+``\ 符号进行格式转换。

最常用的方式就是把两个时间变量转换成秒（\ ``+%s``\ ）然后进行相减计算，例如，从日志文件中获取时间戳，然后和当前时间进行相减计算，以获知日志时间和当前的时间差距。

另外，GNU coreutils >= 5.3还支持支持一种类似以下的\ ``@``\ 格式

.. code:: bash

   date -d @1234567890

可以从时间秒格式传换出时间格式。上述格式还可以使用变量：

.. code:: bash

   date -d @${i} +"%T"

-  可以将指定日期时间转换成时间戳:

.. code:: bash

   $ date -d '06/12/2018 07:21:22' +"%s"
   1528759282
   $ date -d '2018-06-12 07:21:22' +"%s"
   1528759282
   $ date -d "04 June 1989"
   1989年 06月 04日 星期日 00:00:00 CDT

参考
====

-  `SHELL中计算时间差方法 <http://blog.csdn.net/foxliucong/article/details/4225008>`__
-  `linux shell
   时间运算以及时间差计算方法 <http://www.cnblogs.com/chengmo/archive/2010/07/13/1776473.html>`__
-  `date 十分钟前 <http://bbs.chinaunix.net/thread-3611669-1-1.html>`__
-  `shell指定时间的N分钟前怎么计算 <http://bbs.chinaunix.net/thread-4067928-1-1.html>`__
-  `Convert date formats in
   bash <https://stackoverflow.com/questions/6508819/convert-date-formats-in-bash>`__
