.. _uefitool_pcie_bifurcation:

=================================
使用UEFITool配置PCIe bifurcation
=================================

我在设置 :ref:`nasse_c246` BIOS尝试配置 PCIe bifurcation 存在巨大的困扰:BIOS配置缺乏文档，设置繁杂，甚至现在都找不到bifurcation的设置入口。

经过google，我发现 `Guide about how to check PCI-E Bifurcation support of any mainboard <https://www.reddit.com/r/Amd/comments/14bnqh3/guide_about_how_to_check_pcie_bifurcation_support/>`_ 提供了一个软件检查和设置的思路，可以适用于任何主板，也就是通过软件来检查UEFI的配置以及软件方式调整。

这可能是解决当前困境的一个方法和思路，我准备后续实践(待续...)

参考
======

- `What is PCIe Bifurcation? Full Guide <https://riser.maxcloudon.com/en/content/13-what-is-pcie-bifurcation-full-guide>`_
- `Guide about how to check PCI-E Bifurcation support of any mainboard <https://www.reddit.com/r/Amd/comments/14bnqh3/guide_about_how_to_check_pcie_bifurcation_support/>`_
- `[Guide] - How to Bifurcate a PCI-E slot <https://winraid.level1techs.com/t/guide-how-to-bifurcate-a-pci-e-slot/32279>`_
