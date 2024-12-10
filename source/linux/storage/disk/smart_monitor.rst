.. _smart_monitor:

=======================
存储设备S.M.A.R.T监控
=======================

我的二手 :ref:`hpe_dl360_gen9` 服务器使用了一块我很久以前购买的Intel SATA SSD磁盘，不过这块SSD时不时在系统日志中留下触目惊心的Err记录:

.. literalinclude:: smart_monitor/dmesg_ssd_error
   :caption: ``dmesg`` 中SSD磁盘错误日志

.. note::

   我感觉这个 ``Intel 545s Series SSDs`` 的firmware可能存在问题，参考 `Latest Firmware For Solidigm™ (Formerly Intel®) Solid State Drives <https://www.solidigmtech.com.cn/support-page/product-doc-cert/ka-00099.html>`_ 可以看到这款 ``Intel 545s Series SSDs`` 最新的firmware 是 ``004C`` (针对512GB) 和 ``0B3C`` (针对1TB) 。我准备做一次firmware升级来尝试修复这个reset问题。

我想通过存储的 S.M.A.R.T. 技术来检测和监视磁盘的异常:

- 本文的 ``smartctl`` 命令行检查(基础能力)
- :ref:`node_exporter_smartctl_text_plugin` 通过自己部署的 Prometheus + Grafana 监控来直观观察

安装 ``smartmontools``
========================

- 在 :ref:`ubuntu_linux` 环境使用 :ref:`apt` 安装:

.. literalinclude:: smart_monitor/apt_smartmontools
   :caption: 在Ubuntu安装 ``smartmontools``

SMART info
=============

- 检查磁盘设备是否支持和激活SMART:

.. literalinclude:: smart_monitor/smartctl_info
   :caption: ``smartctl -i`` 检查磁盘info信息

我的 :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` SMART 信息如下:

.. literalinclude:: smart_monitor/smartctl_info_sandisk
   :caption: ``smartctl -i`` 检查Sandisk SSD磁盘info信息

.. literalinclude:: smart_monitor/smartctl_info_intel
   :caption: ``smartctl -i`` 检查Intel SSD磁盘info信息

SMART test
============

SMART提供 **两种** 不同的测试:

- Background Mode(后台模式): 后台测试的优先级低，也就是说硬盘仍然会处理常规指令。如果硬盘繁忙，则测试会暂停并且以低负载速度进行，这样不会中断硬盘工作
- Foreground Mode(前台模式): 测试采用了 ``CHECK CONDITION`` 状态必须响应，这种模式只能在不使用的硬盘上进行。

根据经验， **建议采用后台模式**

ATA/SCSI(共有的)测试
-----------------------

Short Test
~~~~~~~~~~~~

``短测试`` 的目的是快速识别有缺陷的硬盘驱动器。因此，短测试的最大持续实践大约2分钟。该测试将磁盘氛围3个不同阶段来检查:

- **Electrical Properties** (电气特性): 控制器测试自己的的电子电路，由于这个测试是每个制造商特有的，因此无法确切解释正在测试的内容。例如测试内部RAM，读写电路或磁头电子器件
- **Mechanical Properties** (机械特性): 测试伺服系统和定位机构的确切顺序也因每个制造商而异
- **Read/Verify** (读取/验证): 读取磁盘的某个区域并验证某些数据，读取的区域的大小和位置也是每个制造商特定的

Long Test
~~~~~~~~~~~~~~

``长测试`` 被设计成生产中的最终测试，与短测试相同，但有 **2点区别** :

- 长测试没有时间限制
- 长测试会 **Read/Verify** (读取/验证) 整个磁盘而不仅仅是一小部分

ATA特有的测试
-------------------

运输测试(Conveyance Tests)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

运输测试(Conveyance Test)可以在短短几分钟内确定硬盘在运输过程中的损坏情况

选择测试(Select Tests)
~~~~~~~~~~~~~~~~~~~~~~~

选择测试可以指定LBA范围，即只扫描指定的LBA区域:

.. literalinclude:: smart_monitor/smartctl_select_tests
   :language: bash
   :caption: 指定LBA进行扫描

而且可以指定多个范围(最多5个)进行扫描:

.. literalinclude:: smart_monitor/smartctl_select_tests_multi
   :language: bash
   :caption: 指定多个LBA范围进行扫描

使用 ``smartctl`` 测试
========================

检查存储设备SMART能力
-----------------------

- 在测试前，可以预估一下不同测试所需时间:

.. literalinclude:: smart_monitor/smartctl_capabilities_sda
   :caption: ``smartctl`` 检查存储设备能力，可以看到预估测试时间

可以看到 ``/dev/sda`` ( :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` )预估测试时间:

.. literalinclude:: smart_monitor/smartctl_capabilities_sda_output
   :caption: ``smartctl`` 检查存储 :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` 设备能力，可以看到预估测试时间
   :emphasize-lines: 25-28

我的另一个磁盘 ``/dev/sdb`` ( Intel 545s系列 ):

.. literalinclude:: smart_monitor/smartctl_capabilities_sdb_output
   :caption: ``smartctl`` 检查存储 Intel 545s系列SSD 设备能力，可以看到预估测试时间
   :emphasize-lines: 25-28

测试
--------

``/dev/sda``
~~~~~~~~~~~~~~

- 执行测试(long test):

.. literalinclude:: smart_monitor/smartctl_long_tests_sda
   :caption: ``smartctl`` 对sda进行长测试，注意参数结合 ``-C`` 表示Foreground Mode

- 长测试输出信息

.. literalinclude:: smart_monitor/smartctl_long_tests_sda_output
   :caption: ``smartctl`` 对sda进行长测试的输出信息
   :emphasize-lines: 8,9

可以看到这个 :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` 仅需要1分钟就能完成长测试 ( 搞笑? 这个长测试和短测试的时间是一样的，不会是虚假吧 )

- 查看测试结果( ``-a`` 参数 ):

.. literalinclude:: smart_monitor/smartctl_view_sda_test_result
   :caption: ``smartctl`` 查看sda测试结果

.. literalinclude:: smart_monitor/smartctl_view_sda_test_result_output
   :caption: ``smartctl`` 查看sda测试结果，可以看到存储健康度(剩余寿命) ``92%``
   :emphasize-lines: 65,78

这里可以看到 ``SSD_LifeLeft(0.01%)`` 表示以 万分比 ``0.01%`` 为单位得到的数值是 ``9126`` ，折算为百分比就是 ``91.26%`` ，所以在 ``Drive_Life_Remaining%`` 的数值就是 ``92``

``/dev/sdb``
~~~~~~~~~~~~~~

- 执行测试(long test):

.. literalinclude:: smart_monitor/smartctl_long_tests_sdb
   :caption: ``smartctl`` 对sdb进行长测试，注意参数结合 ``-C`` 表示Foreground Mode

- 长测试输出信息

.. literalinclude:: smart_monitor/smartctl_long_tests_sdb_output
   :caption: ``smartctl`` 对sdb进行长测试的输出信息
   :emphasize-lines: 8,9

Intel SSD的长测试 **似乎是真测试** 需要花费30分钟完成

- 查看测试结果( ``-a`` 参数  ):

.. literalinclude:: smart_monitor/smartctl_view_sdb_test_result
   :caption: ``smartctl`` 查看sdb(Intel SSD)测试结果

.. literalinclude:: smart_monitor/smartctl_view_sdb_test_result_output
   :caption: ``smartctl`` 查看sdb测试结果，测试了两次都没有完成 ``Extended captive`` : ``Interrupted (host reset)``
   :emphasize-lines: 87,88

比较奇怪，这个 Intel SSD 的SMART测试看不到健康度(剩余寿命 ``ID #245`` )，而且测试状态没有完成 ``Interrupted (host reset)`` 。我连做两次测试都是这样(见高亮部分)

我想了一下，是不是因为这个 ``/dev/sdb`` 正在使用(挂载为系统盘)，所以 ``Foreground Test`` 会被磁盘读写操作中断？

- 改为 ``Background Mode`` ``long tests`` 测试( 去掉 ``-C`` 参数 ):

.. literalinclude:: smart_monitor/smartctl_long_tests_sdb_background_mode
   :caption: ``smartctl`` 对sdb进行长测试，注意 **没有使用** ``-C`` 参数表示 ``Background Mode``

此时会看到立即返回终端提示(不像 ``-C`` 参数需要等待卡住一会):

.. literalinclude:: smart_monitor/smartctl_long_tests_sdb_output_background_mode
   :caption: ``smartctl`` 对sdb进行长测试( ``Background Mode`` )输出信息
   :emphasize-lines: 2

可以看到测试时间依然是30分钟，不过提示是 ``off-line mode`` (之前 ``-C`` 参数显示 ``captive mode`` )

- 果然，采用 ``offline mode`` 方式扫描，就能够正常完成测试，输出结果如下:

.. literalinclude:: smart_monitor/smartctl_long_tests_sdb_background_mode_result_output
   :caption: ``smartctl`` 对sdb进行长测试( ``Background Mode`` )能够正常完成测试，结果输出
   :emphasize-lines: 88

这里看到 ``LifeTime(hours)`` 值是 ``24193`` 这个值就是 ``Power_On_Hours`` 值，也就是磁盘加电时长

很奇怪，为何Intel SSD无法查看 ``Drive_Life_Remaining%`` ?

搜索了一下，看来Intel有自己的诊断工具 `How to Perform Quick/Full Diagnostic of Intel® SSDs Using Intel® Memory and Storage Tool (Intel® MAS) GUI <https://www.intel.com/content/www/us/en/support/articles/000056729/memory-and-storage/ssd-management-tools.html>`_ (这个是Intel Optane SSDs / Memory 设备检测工具)

详细请参考 `Support for Intel® Memory and Storage Tool <https://www.intel.com/content/www/us/en/support/products/202249/memory-and-storage/ssd-management-tools/intel-memory-and-storage-tool.html>`_

参考
========

- `arch linux - S.M.A.R.T. <https://wiki.archlinux.org/title/S.M.A.R.T.>`_
- `Monitor and Analyze Hard Drive Health with Smartctl in Linux <https://www.linuxtechi.com/smartctl-monitoring-analysis-tool-hard-drive/>`_ 非常详细的命令行解析
- `How to check an hard drive health from the command line using smartctl <https://linuxconfig.org/how-to-check-an-hard-drive-health-from-the-command-line-using-smartctl>`_
- `SMART tests with smartctl <https://www.thomas-krenn.com/en/wiki/SMART_tests_with_smartctl>`_
