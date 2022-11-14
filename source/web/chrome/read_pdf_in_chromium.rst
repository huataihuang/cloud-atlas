.. _read_pdf_in_chromium:

========================
在chromium中阅读PDF
========================

在 :ref:`arch_linux` 上使用开源的 ``chromium`` 时，我发现 ``chromium`` 不像 :ref:`firefox` 默认内置了PDF阅读功能。这个使用体验和 :ref:`windows` / :ref:`macos` 平台的 ``chrome`` 使用体验不同，让人非常困扰。

`chrome Extension: PDF Viewer <https://chrome.google.com/webstore/detail/pdf-viewer/oemmndcbldboiebfnladdacbdfmadadm/related>`_ 将 :ref:`firefox` 平台开源的 `Github: mozilla/pdf.js <https://github.com/mozilla/pdf.js/>`_ 带到了 chrome/chromium 平台，能够获得非常流畅的PDF阅读体验。

.. note::

   我没有选择Adobe提供的商用版pdf viewer for chrome，因为不需要复杂的pdf修改和签名功能，也不想绑定在商用平台上。所以选择上述开源实现，精简和轻量级。

参考
=====

- `How To Read PDF In Chromium <https://www.ubuntubuzz.com/2015/04/how-to-read-pdf-in-chromium.html>`_
