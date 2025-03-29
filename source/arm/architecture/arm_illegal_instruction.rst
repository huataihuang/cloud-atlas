.. _arm_illegal_instruction:

=============================================
ARM平台执行程序报错"Illegal instruction"解析
=============================================

我在 :ref:`mini_k3s_deploy` 时遇到运行 ``k3s`` 二进制ARM程序报错::

   Illegal instruction

虽然k3s官方提供的二进制代码是 ``armhf`` 架构，看上去和我 :ref:`pi_1` 所使用的 :ref:`alpine_linux` ``armhf`` 版本匹配，但是实际上还可能有潜在问题:

- :ref:`alpine_linux` 使用 ``musl`` 库，非标准glibc库，可能在执行二进制上存在差异。毕竟很多第三方应用程序都是在比较通用的ubuntu/fedora上编译的
- ARM架构有很多细微差异，早期的树莓派，如 :ref:`pi_1` 和 ``zero w`` 是 :ref:`armv6` 架构( :ref:`arm11` 处理器)
- 参考 `Debian Wiki: ArmHardFloatPort <https://wiki.debian.org/ArmHardFloatPort#Minimum_CPU_.26_FPU>`_ ``hard-float ABI Arm port (armhf) for Debian`` 文档中说明:

  - Debian的 ``armhf`` 最低符合CPU硬件是 ``ARMv7-A`` ，也就是编译时建议采用参数 ``--march=armv7-a``
  - 对于600MHz+ :ref:`armv6` VFPv2处理器不能得到 ``armhf`` 默认的特性支持 - 可以看到针对debian的 ``armhf`` 特性编译的程序可能不支持 :ref:`armv6` 
  - ``summary: Using armv7 as a base``

看来，不能直接使用 ``k3s`` 官方二进制程序在 :ref:`pi_1` 上部署 :ref:`k3s` ，需要自己编译 32位 ``k3s for ARMv6`` 来实现部署，待实践...


