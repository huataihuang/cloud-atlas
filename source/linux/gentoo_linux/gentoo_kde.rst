.. _gentoo_kde:

=======================
Gentoo KDE
=======================

Install
=========

- The kde-plasma/plasma-meta package provides the full Plasma desktop:

.. literalinclude:: gentoo_kde/install_plasma-meta
   :caption: ``kde-plasma/plasma-meta``

- kde-plasma/plasma-desktop provides a very basic desktop, leaving users free to install only the extra packages they require - or rather, figure out missing features on their own:

.. literalinclude:: gentoo_kde/install_plasma-desktop
   :caption: ``kde-plasma/plasma-desktop``

.. note::

   Please note that installing just kde-plasma/plasma-desktop will exclude important packages needed for KDE Plasma to function, such as kde-plasma/powerdevil (power management, suspend and hibernate options), kde-plasma/systemsettings, and many more.

Addition
--------------

- My install:

.. literalinclude:: gentoo_kde/install_addition
   :caption: my installation with addition


Refer
=======

- `gentoo linux wiki: KDE <https://wiki.gentoo.org/wiki/KDE>`_
- `Plasma-browser-integration <https://userbase.kde.org/Plasma-browser-integration>`_
