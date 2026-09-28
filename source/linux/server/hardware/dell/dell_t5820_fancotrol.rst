.. _dell_t5820_fancotrol:

==========================
Dell T5820风扇控制
==========================

.. note::

   目前我简单使用 ``i8kutils`` 命令行控制主机风扇转速， ``fancontrol`` 服务尚未尝试(待实践)

由于 Dell Precision 桌面工作站（如 :ref:`dell_t5820` ）与 Dell PowerEdge Rack 服务器的底层架构不同，T5820 主板上并没有配备 BMC/iDRAC 芯片，因此无法直接通过 :ref:`ipmitool` 命令来控制风扇。 ipmitool 是专用于带外管理芯片（如 iDRAC/IPMI）的工具，在 T5820 上运行会提示找不到 IPMI 设备。

``dell-smm-hwmon`` 内核模块
==============================

Dell 的 Linux 内核中自带了一个名为 ``dell-smm-hwmon`` 的驱动模块(专门用于控制 Dell 笔记本和工作站的风扇与读取温度)，我在 :ref:`ubuntu_linux` 启动以后就检查到系统已经有溢恶 ``dell_smm_hwmon`` 模块自动加载，不过默认情况下这个驱动处于只读状态，需要给它传递参数开启写入(控制)权限:

.. literalinclude:: dell_t5820_fancotrol/dell-smm-hwmon
   :caption: 配置 ``dell-smm-hwmon`` 驱动模块

- ``restricted=0`` : 解除普通用户/系统的写入限制(允许控制风扇)
- ``ignore_dmi=1`` / ``force=1`` : 强制覆盖 Dell 工作站主板对风扇控制的默认拒绝保护，允许用户态软件接管

.. note::

   系统默认已经有一个 ``/etc/modprobe.d/dell-smm-hwmon.conf`` 配置文件，内容就是设置该模块只读状态:

   .. literalinclude:: dell_t5820_fancotrol/dell-smm-hwmon_readonly
      :caption: 默认只读状态配置 ``/etc/modprobe.d/dell-smm-hwmon.conf``

   需要传递参数让这个模块能够读写，才能完成本文的后续操作

``dell-smm-hwmon`` 模块的参数修订以后，检查 ``/sys/class/hwmon/`` 路径下属于 ``dell_smm`` 的节点，其中的 ``pwm1`` 等文件要具备 **可写权限(rw)** :

.. literalinclude:: dell_t5820_fancotrol/pwm_rw
   :caption: 确认风扇对应sys文件是否可读写

输出类似:

.. literalinclude:: dell_t5820_fancotrol/pwm_rw_output
   :caption: 风扇对应sys文件pwm*显示为 ``rw``

``i8kutils`` 控制风扇级数
==========================

``i8kutils`` 是专门针对 Dell 设备风扇控制的经典工具，底层依赖 ``dell-smm-hwmon`` :

- 安装工具:

.. literalinclude:: dell_t5820_fancotrol/install_i8kutils
   :caption: 安装 ``i8kutils``

- 检查当前风扇状态与转速

.. literalinclude:: dell_t5820_fancotrol/i8kctl
   :caption: 运行 ``i8kctl``

输出显示类似:

.. literalinclude:: dell_t5820_fancotrol/i8kctl_output
   :caption: 运行 ``i8kctl``

.. csv-table:: i8kctl输出说明
   :file: dell_t5820_fancotrol/i8kctl_output.csv
   :widths: 10,10,40,40
   :header-rows: 1

- 设置转速提升到 2 档(高速)然后再恢复低速以确认 ``i8kctl`` 工作:

.. literalinclude:: dell_t5820_fancotrol/i8kctl_2
   :caption: 设置高速转速

原生 ``fancontrol`` + 内核 ``dell-smm-hwmon`` 驱动
=====================================================

- 安装 ``lm-sensors`` 和 ``fancontrol`` 工具

.. literalinclude:: dell_t5820_fancotrol/install_fancontrol
   :caption: 安装 ``lm-sensors`` 和 ``fancontrol``

- 运行自动配置脚本

.. literalinclude:: dell_t5820_fancotrol/pwmconfig
   :caption: 自动配置脚本

``pwmconfig`` 会逐个测试主板上的 PWM 接口并询问你是否能听到风扇停转/变慢。跟着提示一步步确认后，它会自动在 ``/etc/fancontrol`` 中生成风扇与温度传感器的映射配置文件。

- 最后启动并开机自启 ``fancontrol`` 服务

.. literalinclude:: dell_t5820_fancotrol/systemctl_fancontrol
   :caption: ``fancontrol`` 服务

参考
=====

- gemini
