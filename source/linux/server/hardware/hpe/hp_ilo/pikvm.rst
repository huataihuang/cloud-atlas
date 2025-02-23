.. _pikvm:

==================
PiKVM
==================

在使用 HP iLO 时，最有用的功能应该时Remote Console，以及WEB管理的服务器状态检查和开关机功能。这些功能实际上是多种底层技术的结合，例如 :ref:`ipmi` 和 :ref:`lm_sensor` 。

很多时候，在数据中心，我们还会使用远程KVM，也就是远程 ``键盘/视频/鼠标`` ，技术原理既简单又复杂:

- :ref:`usb_gadgets_on_pi_zero` 方案能够提供一个全系统USB输入设备
- 结合 VNC / WebRC 技术可以构建一个WEB方式的图形桌面

开源项目 `PiKVM.org <https://pikvm.org/>`_ 是一个集成多个功能的生产级基于 :ref:`raspberry_pi` 构建的KVM over IP设备(DIY)

.. figure:: ../../../../../_static/linux/server/hardware/hpe/hp_ilo/pikvm_webui.png

``PiKVM`` 可以视为一个HP iLO的廉价开源平替设备，能够将不支持企业级远程管理的服务器转变成全功能的适合数据机房使用设备。

.. note::

   资料整理，后续有机会再尝试实践
