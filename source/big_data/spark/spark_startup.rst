.. _spark_startup:

==============
Spark快速起步
==============

安装单机Spark
===============

`Spark官方下载 <https://spark.apache.org/downloads.html>`_ 提供了3种不同的预先编译执行软件包和源代码。对于初次学习，如果要使用Hadoop上运行Spark显然首先要部署Hadoop，显然对于初学者有一定门槛。所以，我们可以下载无需hadoop平台的运行版本 - `spark-3.0.0-bin-without-hadoop.tgz <https://www.apache.org/dyn/closer.lua/spark/spark-3.0.0/spark-3.0.0-bin-without-hadoop.tgz>`_ 。

简单的 standalone 部署模式不需要部署Mesos或者YARN集群管理器，可以手工家在一个独立运行的集群或者手工启动master和workers，或者使用 launch脚本。

.. note::

   默认Spark是关闭了安全配置，所以默认存在攻击可能，在实际部署使用Spark是需要配置好完整安全设置。

- 解压缩::

   tar xfz spark-3.0.0-bin-without-hadoop.tar.gz
   mv spark-3.0.0-bin-without-hadoop spark-3
   cd spark-3

手工启动Spark集群
=================

- 执行以下命令启动standalone master服务器::

   ./sbin/start-master.sh

一旦启动，master服务器将输出显示 ``spark://HOST:PORT``

我在 :ref:`multi_jdk_on_macos` ，当前JDK版本设置为 OpenJDK 1.8 ，执行上述运行后提示错误，根据提示检查错误日志显示::

   Spark Command: /Users/huatai/.jenv/versions/1.8/bin/java -cp /Users/huatai/spark-3/conf/:/Users/huatai/spark-3/jars/* -Xmx1g org.apache.spark.deploy.master.Master --host L-V1L5LVDL-1304.local --port 7077 --webui-port 8080
   ========================================
   Error: A JNI error has occurred, please check your installation and try again
   Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/log4j/spi/Filter
   	at java.lang.Class.getDeclaredMethods0(Native Method)
   	at java.lang.Class.privateGetDeclaredMethods(Class.java:2701)
   	at java.lang.Class.privateGetMethodRecursive(Class.java:3048)
   	at java.lang.Class.getMethod0(Class.java:3018)
   	at java.lang.Class.getMethod(Class.java:1784)
   	at sun.launcher.LauncherHelper.validateMainClass(LauncherHelper.java:544)
   	at sun.launcher.LauncherHelper.checkAndLoadMain(LauncherHelper.java:526)
   Caused by: java.lang.ClassNotFoundException: org.apache.log4j.spi.Filter
   	at java.net.URLClassLoader.findClass(URLClassLoader.java:382)
   	at java.lang.ClassLoader.loadClass(ClassLoader.java:418)
   	at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:352)
   	at java.lang.ClassLoader.loadClass(ClassLoader.java:351)
   	... 7 more

这个报错表明缺少 ``org/apache/log4j/spi/Filter`` 类支持。待续...
