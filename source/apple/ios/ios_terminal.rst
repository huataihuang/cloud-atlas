.. _ios_terminal:

===================
iOS 终端程序
===================

作为Linux运维和后台开发人员，以及 :ref:`mobile_work` 爱好者，需要一个能够在iOS/iPadOS上良好工作的Unix 终端。当然，比不上Android平台的 :ref:`termux` 这么功能完善，但至少能够有一个支持中英文工作的终端，以及本地轻量级开发( :ref:`vim` / :ref:`python` 等)。

目前我所了解和简单试用的终端软件:

- :ref:`a-shell` : 完全原生iOS程序，意味着轻量级快速和节能；但是，正是因为原生，也带来了极大的限制:

  - 所有程序都需要使用特定的框架改写port，导致只有不多的程序得到移植(python/clang/javascript)，缺乏很多Unix/Linux底层结合的程序(如果你恰好需要)
  - 对中文文件编辑存在光标定位问题，这点非常困扰

- :ref:`ish` : 使用 :ref:`qemu` 运行的定制化 :ref:`alpine_linux` ，由于是完整虚拟化，所以几乎可以认为这是一个完整的Linux系统，优点和缺点都很明显:

  - 完整的最轻量级Linux发行版，特别适合移动设备，启动非常迅速，远比 :ref:`utm` 运行的 :ref:`arch_linux` :ref:`debian` 等大型发行版快速
  - 作为路由器、 :ref:`docker` 所选择的底层Linux发行版， :ref:`alpine_linux` 具备了非常完善的Linux能力
  - 官方虽然不断更新，但是毕竟需要做迁移定制，所以和 :ref:`alpine_linux` 最新版本依然有很大的gap
  - 如果需要比 :ref:`a-shell` 更为复杂的本地开发环境，则非常推荐使用 :ref:`ish`

- :ref:`utm` : 完整的 :ref:`qemu` 虚拟化解决方案，目标是运行各种操作系统，所以也意味着庞大复杂

  - 如果你的设备性能非常强悍，并且能够承受由于完全虚拟化的损耗，并且你希望能够得到主流Linux/Windows/macOS发行版的运行，那么只有选择 ``utm``
  - 过于复杂和沉重，我尝试了ARM架构的 :ref:`arch_linux` 虚拟机，在 :ref:`ipad_pro1` 上启动非常耗时并且容易出错，所以可能需要非常新的硬件才能顺畅运行
