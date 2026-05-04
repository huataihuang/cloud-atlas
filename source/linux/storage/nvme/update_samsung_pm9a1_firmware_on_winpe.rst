.. _update_samsung_pm9a1_firmware_on_winpe:

==============================================
在WinPE环境更新Samsung PM9A1 firmware
==============================================

我的 :ref:`mbp15_late_2013` 已经使用了12年了，期间应为原装SSD存储损坏，我更换了 :ref:`samsung_pm9a1` 第三方SSD，虽然初步测试没有遇到问题(不影响休眠)，但是我最近一次重新安装macOS Big Sur时，意外发现系统启动非常缓慢、应用程序启动慢、编译 :ref:`sphinx_doc` 缓慢，虽然多次尝试 :ref:`fix_macbook_slow` 并最终偶然恢复，但是推断下来的原因是 :ref:`samsung_pm9a1` 早期firmwarm在非原生系统下会导致严重的性能衰减:

- 卡顿原理： macOS 会在空闲时或启动时清理无效块。如果固件不兼容，主控会锁死总线进行垃圾回收，此时系统 UI 就会失去响应（彩虹球）。
- 验证方法： 在 System Information -> NVMExpress 检查 Firmware Revision，我的版本是 ``GXA7601Q`` ，gemini告知我这是一个中期过渡版本，还是存在缺陷隐患(APFS Trim 时存在显著的响应延迟，在某些负载下会出现 写入速度减半 或 读取性能大幅波动 的缺陷)需要升级

我在Linux环境下尝试 :ref:`update_samsung_pm9a1_firmware` 失败，最近为了解决 :ref:`oclp_macos` 潜在的硬件风险，我决定为 :ref:`mbp15_late_2013` 升级 :ref:`samsung_pm9a1` firmware，以彻底解决macOS环境下因为Trim缺陷卡顿的问题。这次为了绕开Linux下升级困难，我决定简化为采用 :ref:`winpe` 环境来运行Windows下的Samsung PM9A1 firmware更新程序。

- 根据之前在Linux平台上 :ref:`update_samsung_pm9a1_firmware` 实践已经检查过当前Samsung PM9A1 firmware  版本:

.. literalinclude:: update_samsung_pm9a1_firmware/nvme_list_output
   :caption: 工作正常的 :ref:`samsung_pm9a1` ，注意firmware版本 ``GXA7601Q``

根据gemini提示，建议将firmware升级到 GXA7801Q (或更高)，以避免“掉速”和“读取波动”缺陷，尤其是在 macOS 环境下。

:strike:`Lenovo 官方分发包（最推荐，兼容性最强）：联想提供的固件更新程序（如 FWNV35 系列）通常是全通用的` ，不限制主板， **但是我的实践发现联想的firmware依然无法在零售无OEM厂商的PM9A1上使用**

访问 `Lenovo PC Technical Support <https://pcsupport.lenovo.com/>`_ 搜索 ``PM9A1 Firmware Update`` 可以找到 `Samsung PM9A1 NVMe Solid State Drive Firmware Update Utility for Windows 10 (64-bit), Windows 11 (64-bit) - Desktops <https://pcsupport.lenovo.com/us/en/downloads/ds561921>`_ 

.. warning::

   我原计划是在WinPE中完成Samsung PM9A1 firmware更新，但是实际运行 ``由于找不到 X:\windows\System32\comctl32.dll ，无法继续执行代码。重新安装程序可能会解决此问题`` ，所以我最终放弃这个方法。虽然可能从其他Windows上复制 ``comctl32.dll`` 或许可以解决，但我没有尝试

   另外，我尝试在 :ref:`firpe` (一种更为完整的WinPE类型维护系统)执行更新程序也是失败 ``Runtime Error (at -1:0): Cannot Import EXPANDCONSTANT.``


