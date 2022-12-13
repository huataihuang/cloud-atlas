.. _bash_multi_variable_assigment:

============================
在bash中多变量赋值
============================

在很多时候需要给一组变量赋值，例如检查日志切分后按字段赋值，显然批量赋值是很自然的。在 :ref:`python` 中很容易实现的多变量赋值::

   var1, var2, var3 = "I am var1", "I am var2", "I am var3"

使用 ``<<<``
==============

在bash中处理稍微有些不同::

   read var1 var2 var3 <<< $(echo "I am var1" "I am var2" "I am var3" )

举例，获取Linux系统的负载统计结果::

   read load1 load5 load15  <<< $(echo $(uptime | tr -d " " | awk -F "[:,]" '{print $8" "$9" "$10}'))

使用 ``< <()``
===============

另一种方式是使用 ``< <()`` (我发现在 Google :ref:`shell_style` 案例中使用了这种方法)::

   read CORES MEMORY < <(echo $vm_size | awk -F"[a-zA-Z]" '{print $1" "$2}')
   
   MEMORY=$(($MEMORY*1024))
   echo "CORES: $CORES"
   echo "MEMORY: $MEMORY"

参考
=======

- `Linux bash: Multiple variable assignment <https://stackoverflow.com/questions/1952404/linux-bash-multiple-variable-assignment>`_
- `(Baeldung) Linux Bash: Multiple Variable Assignment <https://www.baeldung.com/linux/bash-multiple-variable-assignment>`_
- `shell给多个变量赋值的方法总结 <https://www.cnblogs.com/sunss/archive/2011/02/09/1950268.html>`_
