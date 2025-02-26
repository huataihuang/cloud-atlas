.. _nmi_iock_error:

=========================
``NMI: IOCK error``
=========================

二手 :ref:`hpe_dl360_gen9` 故障无法启动后，我重新购买了 :ref:`hpe_dl380_gen9` 准系统。因为猜测可能是原先 DL360 gen9 主板故障，所以我只购买了 DL380 gen9准系统，将原来服务器的CPU和内存全部搬迁到新 DL380 gen9准系统 使用。果然能够开机使用了。

但是，好景不长，使用没有几天，一次重启后发现服务器没有启动起来，终端控制台不断输出如下报错:

.. literalinclude:: nmi_iock_error/console.log
   :caption: 控制台输出 ``NMI: IOCK error`` 报错

检查
=======

- ``dmesg -T`` 检查启动日志有一些疑问点:

.. literalinclude:: nmi_iock_error/dmesg
   :caption: ``dmesg`` 的一些报错信息

目前重启系统正常运行，但系统日志中有一些不太正常的内容有待排查

- Red Hat 建议设置 ``kernel.panic_on_io_nmi = 1`` sysctl:

.. literalinclude:: nmi_iock_error/sysctl.conf
   :caption: 设置 ``kernel.panic_on_io_nmi = 1`` sysctl 

然后执行 ``sysctl -p`` 刷新设置

完成后检查 ``nmi`` 相关内核设置:

.. literalinclude:: nmi_iock_error/sysctl_a
   :caption: ``sysctl -A`` 检查

``NMI: IOCK error`` 可能是硬件IO相关错误，后续待观察

再次发作
=========

经过几天开关机，服务器再次拒绝启动，不过 iLO 管理界面可以登陆，检查 ``Integrated Management Log`` 显示报错:

参考
======

- `What does the message "NMI: IOCK error" mean? <https://access.redhat.com/solutions/42261>`_
