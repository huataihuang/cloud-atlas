.. _nvim_ide_fix:

=================
NeoVim IDE修正
=================

在 :ref:`colima` 中我构建了 :ref:`debian_tini_image` ，其中通过Dockerfile自动完成 :ref:`nvim_ide` 集成。这个步骤使用了我比较早期的 `GitHub: huataihuang/cloud-studio <https://github.com/huataihuang/cloud-studio>`_ ，也即是2年前的nvim配置快照。

这就带来一个问题，最新的 :ref:`nvim` 在使用较早的配置时会提示WARNING:

.. literalinclude:: nvim_ide_fix/nvim_warning
   :caption: 由于lua配置陈旧导致nvim提示WARNING

根据提示检查 ``:checkhealth vim.deprecated`` 输出可以看到详细的告警信息:

.. literalinclude:: nvim_ide_fix/nvim_warning_detail
   :caption: 由于lua配置陈旧导致nvim提示WARNING相信信息

待修复...
