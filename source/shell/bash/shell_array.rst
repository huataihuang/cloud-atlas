.. _shell_array:

==============
SHELL数组
==============

在shell中，用括号来表示数组，数组元素用 ``空格`` 符号分割开。定义数组的一般方法有：

.. code:: bash

   array=(value1 value2 ...... valueN)             #从下标0开始依次赋值
   array=([1]=value1 [2]=value2 [0]=value0)        #指定下标赋值
   declare -a array=(value1 value2 ...... valueN)  #声明+赋值，也可以只声明
   unixtype=('Debian' 'Red Hat' 'Fedora')          #如果元素有空格，就要用引号
   set| grep array                                 #利用set查看数组赋值情况

此外页可以通过 ``read`` 的交互方式来定义数组：

.. code:: bash

   # read -a array                  #-a表示从标准输入读入数组，遇到换行为止
   1 2 3 4 5
   # echo "${array[@]}"
   1 2 3 4 5

可以通过如下方法清除数组：

.. code:: bash

   unset array                     #清除数组
   unset array[1]                 #清除数组的指定元素

数组变量
========

.. code:: bash

   # 取得数组元素的个数
   length=${#array_name[@]}
   # 或者
   length=${#array_name[*]}
   # 取得数组单个元素的长度
   lengthn=${#array_name[n]}
   #取得数组下标的值
   ${!array[@]}
   #从数组的n位置开始取m个元素
   ${array[@]:n:m}

示例如下：

.. code:: bash

   [root@localhost ~]# unixtype=('Debian' 'Red Hat' 'Fedora')
   [root@localhost ~]# echo ${#unixtype[@]}
   3
   [root@localhost ~]# echo ${#unixtype[*]}
   3
   [root@localhost ~]# echo ${#unixtype[1]}
   7
   [root@localhost ~]# echo ${!unixtype[@]}
   0 1 2
   [root@localhost ~]# echo ${!unixtype[2]}
                  --> 无结果输出
   [root@localhost ~]# echo ${unixtype[@]:1:2}
   Red Hat Fedora
   [root@localhost ~]# echo ${unixtype[@]:1:3}
   Red Hat Fedora

数组的常用操作
==============

-  命令执行结果放入数组

.. code:: bash

   [root@361way ~]# array=($(ls | grep '.sh'))
   #或
   [root@361way ~]# array=(`ls | grep '.sh'`)
   [root@361way ~]# echo ${array[@]}
   11.sh a.sh b.sh del_log.sh getcoreinfo.sh ntp.sh read.sh rrs.sh script.sh

-  读入字符串，给数组赋值

.. code:: bash

   i=0
   n=5
   while [ "$i" -lt $n ] ; do                     #遍历5个输入
     echo "Please input strings ... `expr $i + 1`"
     read array[$i]                                #数组赋值
     b=${array[$i]}
     echo "$b"
     i=`expr $i + 1`                              #i递增
   done

-  字符串的字母逐个放入数组并输出

.. code:: bash

   # cat a2.sh
   chars='abcdefghijklmnopqrstuvwxyz'
   i=0
   while [ $i -lt ${#chars} ] ; do    # ${#char}是字符串长度
      #echo ${chars:$i:1} $i
      array[$i]=${chars:$i:1}            #从$i取1个字节
      echo ${array[@]} $i
      #echo ${array[$i]} $i
      i=`expr $i + 1`
   done

-  判断一个变量是否在数组中

.. code:: bash

   for i in ${array[@]};do
      if [ "$i" = "${member}" ];then
      ....
      fi
   done

-  构建二维数组

.. code:: bash

   a=('1 2 3' '4 5 6' '7 8 9')             #赋值，每个元素中都有空格
   for i in ${a[@]} ; do
      b=($i)                                    #赋值给b，这样b也是一个数组
      for j in ${b[@]};do                  #相当于对二元数组操作
      ......
      done
   done

-  文件内容读入数组

.. code:: bash

   # cat /etc/shells | tr "\n" " " >/tmp/tmp.file                      #回车变空格
   # read -a array < /tmp/tmp.file                                       #读入数组
   # set| grep array
   array=([0]="/bin/sh" [1]="/bin/bash" [2]="/sbin/nologin" [3]="/bin/tcsh" [4]="/bin/csh" [5]="/bin/dash")

数组使用的常用方法
==================

目前我在脚本中使用数组非常简单:

.. code:: bash

   #申明数组
   ARRAY=()
   #填写数据
   ARRAY+=('foo')
   ARRAY+=('bar')

此外，如果有一行数据从文件中读出，默认空格分隔，则可以直接复制为数组。以下脚本获取系统中所有D住进程的pid和执行进程名字

.. code:: bash

   # D进程pid和command   分隔符用,
   # 举例: 213912,./test_uninterruptible
   dPidCmd=()
   dPidCmd=`ps r -A | grep " D" | grep -v "\[load_calc\]" | awk '{print $1","$5}'`

打印数组:

.. code:: bash

   echo ${array[@]}

其他简单案例

.. code:: bash

   #!/bin/bash
   array=("A" "B" "ElementC" "ElementE")
   for element in "${array[@]}"
   do
       echo "$element"
   done

   echo
   echo "Number of elements: ${#array[@]}"
   echo
   echo "${array[@]}"

案例
====

-  构建数组

::

   array=(bill chen bai hu)

-  直接读取一行文本来构建array

.. code:: bash

   array=(`tail -1 example.txt`)

以上命令也可以使用

.. code:: bash

   array=($(tail -1 example.txt))

这里假设文本是 ``bill chen bai hu``

-  获取数组的长度

::

   num=${#array[@]}

输出结果\ ``4`` (共4个单词)

-  获取数组某个单元的长度

::

   len=${#array[3]}

输出结果\ ``2``\ ，即第4个单词是2个字符（注意，数组的下标从0开始）

-  输出数组的某个单元

::

   echo ${array[0]}

输出内容 ``bill``

在array每个元素添加字符串
=========================

参考 `How to append a string to each element of a Bash array? <https://stackoverflow.com/questions/6426142/how-to-append-a-string-to-each-element-of-a-bash-array>`_

::

   function gen_vm_rss()
   {
       time_stamp=`date +%Y-%m-%d" "%H:%M:%S`
       vm_rss_array=( $(ps aux | grep qemu | grep -v grep | awk '{print $13"|"$6}') )
       vm_num=${#vm_rss_array[@]}
       for ((i=0;i<vm_num;i++));do
           vm_rss_array[i]="$time_stamp|${vm_rss_array[i]}"
           echo "${vm_rss_array[i]}"
       done
   }

向函数传递数组
==============

之前写了一个简单的脚本，传递一个文件名列表数组给函数，但是发现在函数中，只接收到数组的第一个元素值：

.. code:: bash

   function download_package() {
       local package_list=$1

       for package in $package_list; do
           wget -q $package
       done
   }

   package_list=(
   http://mirrors.163.com/centos/7.6.1810/os/x86_64/Packages/samba-4.8.3-4.el7.x86_64.rpm
   http://mirrors.163.com/centos/7.6.1810/os/x86_64/Packages/samba-client-4.8.3-4.el7.x86_64.rpm
   http://mirrors.163.com/centos/7.6.1810/os/x86_64/Packages/samba-client-libs-4.8.3-4.el7.x86_64.rpm
   http://mirrors.163.com/centos/7.6.1810/os/x86_64/Packages/samba-common-4.8.3-4.el7.noarch.rpm
   http://mirrors.163.com/centos/7.6.1810/os/x86_64/Packages/samba-common-libs-4.8.3-4.el7.x86_64.rpm
   http://mirrors.163.com/centos/7.6.1810/os/x86_64/Packages/samba-common-tools-4.8.3-4.el7.x86_64.rpm
   http://mirrors.163.com/centos/7.6.1810/os/x86_64/Packages/samba-libs-4.8.3-4.el7.x86_64.rpm
   )

   download_package $package_list

通过debug方式打印函数 ``download_package()`` 中变量 ``$package_list`` ，发现确实只拿到了数组的第一个元素值。

这个错误是因为传递给函数的数组实际上是空格分割的多个字符串，这样数组实际上就变成了传递给函数的多个变量 ``$1 $2 $3 $4 $5 $6 $7`` ，导致在函数内部如果以为数组是一个变量传递进来，只取 ``$1`` 是拿不到完整的数组的。

解决方法参考 `Passing Array to Function in Bash shell <https://www.nixcraft.com/t/passing-array-to-function-in-bash-shell/460>`_ 也就是传递数组时，在数组外围加上引号，这样就转变成1个字符串变量。再在函数内部把这个单一字符串转换回数组:

.. code:: bash

   function download_package() {
       local package_list=( $(echo "$1") )

       for package in $package_list; do
           wget -q $package
       done
   }

   package_list=(
   ...
   )

   download_package "$(echo ${package_list[@]})"

参考
====

- `shell数组的定义与应用 <http://www.361way.com/shell-array/4965.html>`_
- `Arrays in unix shell? <https://stackoverflow.com/questions/1878882/arrays-in-unix-shell>`_
