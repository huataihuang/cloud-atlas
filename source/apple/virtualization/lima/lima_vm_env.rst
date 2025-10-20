.. _lima_vm_env:

============================
Lima虚拟机内部环境变量配置
============================

对于Linux系统的环境变量，通用配置是 ``/etc/environment`` 。在Lima虚拟机内部，通过注入VM该配置文件内容，可以影响虚拟机的运行环境，例如代理设置



参考
======

- `lima/examples/default.yaml#L383_L390 <https://github.com/lima-vm/lima/blob/v0.16.0/examples/default.yaml#L383_L390>`_
