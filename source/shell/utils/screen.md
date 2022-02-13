GNU Screen是一个终端多路复用管理器，用于同时并发的多路虚拟控制台，允许用在一个登录会话中访问分隔的会话，或者断开并重连一个终端的会话。这样，用户远程登录到服务器，即使关闭终端，也可以再次登录服务器访问上次断开的终端。

# 独立编译安装`screen`

从 [GNU Screen官网](https://www.gnu.org/software/screen/) 下载源代码可以自己编译安装最新版本，编译以后生成的`screen`可执行程序可以直接使用。

不过，启动这个自己编译的`screen`显示连接的sockets目录可能和发行版自带的screen所设置的SockDir不同，则可能看不到之前的保持的会话。解决方法参考 [How do I reattach to a screen session when the socket is there, but screen won't use it?](https://superuser.com/questions/445301/how-do-i-reattach-to-a-screen-session-when-the-socket-is-there-but-screen-wont) 也就是通过设置 `SCREENDIR` 环境变量来实现

```
export SCREENDIR="/var/run/screen"
```

> 不过，我遇到升级到screen 4.06 版本无法访问 4.03 的sockets的问题。

# screen使用tips

## screen窗口

按 `Ctrl-a`，然后在当前窗口中按双引号键（`"`），就可以看到会话中可用窗口的列表

终止当前窗口的方法是，在窗口的 shell 提示上输入 `exit`，或者按键盘快捷键 `Ctrl-a`，然后按 `k`（小写的字母 `K`，代表 “kill”）。如果使用后一种方法，那么在窗口底部会出现一个警告，要求您确认要杀死此窗口。按 `y`（小写的字母 Y，代表 “yes”）确认，或按 `n`（小写的字母 N，代表 “no”）拒绝。

* 指定窗口名称

指定窗口名称的方法：激活窗口，按 `Ctrl-a A`（大写的字母 `A`，代表 “Annotate”），根据需要按 Backspace 删除现有的名称，然后在提示上输入一个有意义的名称

* 修改窗口编号

由于screen支持`0~9`的10个快捷窗口切换，所以窗口编号非常重要。如果有部分窗口关闭，空出了`0~9`之间的编号，则可以修改其他窗口来填补这个编号。

修改方法：激活窗口，按 `Ctrl-a`，然后输入`:number x`（`x`就是新窗口编号数字）

* 修改窗口顺序

如果要重排窗口顺序，按下`Ctrl-a`，然后输入`:windowlist`。此时在显示的窗口列表中，使用`.`将窗口下移，使用`,`将窗口上移。

## screen复制和粘贴

> 参考 [How to copy the GNU Screen copy buffer to the clipboard?](https://stackoverflow.com/questions/16111548/how-to-copy-the-gnu-screen-copy-buffer-to-the-clipboard)

* 进入`screen`的复制模式： `Ctrl-a`，然后按下`[`
* 此时可以通过类似vi的方式进行光标移动
* 在需要复制的行，按下`space`空格按键，表示选择。然后再按下`j`或者`k`上下移动光标，复制需要复制的所有行
* 再次按下`space`空格按键，结束复制。此时两次`space`按键之间的所有行都被复制到缓存中
* 粘贴命令是 `Ctrl-a`，然后按下`]`，内容复制到当前位置

## screen配置

**可以使用状态栏在视觉上进一步区分各个窗口** : 主目录中创建包含以下代码的 `.screenrc` 文件

```
hardstatus on
hardstatus alwayslastline
hardstatus string "%{.bW}%-w%{.rW}%n %t%{-}%+w %=%{..G} %H %{..Y} %m/%d %C%a "
```

* `.screenrc`配置案例一(推荐)：

```bash
source /etc/screenrc
altscreen off
hardstatus none
caption always "%{= wk}%{wk}%-Lw%{rw} %n+%f %t %{wk}%+Lw %=%c%{= R}%{-}"

shelltitle "$ |bash"
defscrollback 50000
startup_message off
escape ^aa

termcapinfo xterm|xterms|xs|rxvt ti@:te@ # scroll bar support
term rxvt # mouse support

bindkey -k k; screen
bindkey -k F1 prev
bindkey -k F2 next
bindkey -d -k kb stuff ^H
bind x remove
bind j eval "focus down"
bind k eval "focus up"
bind s eval "split" "focus down" "prev"
vbell off
shell -bash
```

* `.screenrc`配置案例二：

```bash
# GNU Screen - main configuration file
# All other .screenrc files will source this file to inherit settings.
# Author: Christian Wills - cwills.sys@gmail.com

# Allow bold colors - necessary for some reason
attrcolor b ".I"

# Tell screen how to set colors. AB = background, AF=foreground
termcapinfo xterm 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'

# Enables use of shift-PgUp and shift-PgDn
termcapinfo xterm|xterms|xs|rxvt ti@:te@

# Erase background with current bg color
defbce "on"

# Enable 256 color term
term xterm-256color

# Cache 30000 lines for scroll back
defscrollback 30000

# New mail notification
backtick 101 30 15 $HOME/bin/mailstatus.sh

hardstatus alwayslastline
# Very nice tabbed colored hardstatus line
hardstatus string '%{= Kd} %{= Kd}%-w%{= Kr}[%{= KW}%n %t%{= Kr}]%{= Kd}%+w %-= %{KG} %H%{KW}|%{KY}%101`%{KW}|%D %M %d %Y%{= Kc} %C%A%{-}'

# change command character from ctrl-a to ctrl-b (emacs users may want this)
#escape ^Bb

# Hide hardstatus: ctrl-a f
bind f eval "hardstatus ignore"
# Show hardstatus: ctrl-a F
bind F eval "hardstatus alwayslastline"
```

> 在 [A nice default screenrc](https://gist.github.com/ChrisWills/1337178) 也有一个类似推荐配置。[What are useful .screenrc settings?](https://serverfault.com/questions/3740/what-are-useful-screenrc-settings)推荐了[byobu](http://byobu.org/)(屏风)作为screen或者tmux（默认，如果安装了tmux的话）的wrap工具，提供了非常友好的交互方法。

# screen快捷键

* `C-a ?`	显示所有键绑定信息
* `C-a w`	显示所有窗口列表
* `C-a C-a`	切换到之前显示的窗口
* `C-a c`	创建一个新的运行shell的窗口并切换到该窗口
* `C-a n`	切换到下一个窗口
* `C-a `p	切换到前一个窗口(与C-a n相对)
* `C-a 0..9`	切换到窗口0..9
* `C-a a`	发送 C-a到当前窗口
* `C-a d`	暂时断开screen会话
* `C-a K`	杀掉当前窗口
* `C-a [`	进入拷贝/回滚模式

| Key | Action | Notes |
| ---- | ---- | ---- |
| `Ctrl+a c` | new window |
| `Ctrl+a n` | next window |
| `Ctrl+a p` | previous window |
| `Ctrl+a "` | select window from list |
| `Ctrl+a Ctrl+a` |	previous window viewed |	 	 
| `Ctrl+a S` | split terminal horizontally into regions	`Ctrl+a c` to create new window there |
| `Ctrl+a` | split terminal vertically into regions	Requires screen >= 4.1 |
| `Ctrl+a :resize` | resize region |
| `Ctrl+a :fit` | fit screen size to new terminal size	`Ctrl+a F` is the same. Do after resizing xterm |
| `Ctrl+a :remove` | remove region `Ctrl+a X` is the same |
| `Ctrl+a tab` | Move to next region |	  	 
| `Ctrl+a d` | detach screen from terminal	Start screen with `-r` option to reattach |
| `Ctrl+a A` | set window title	|
| `Ctrl+a x` | lock session	Enter user password to unlock |
| `Ctrl+a [` | enter scrollback/copy mode	Enter to start and end copy region. `Ctrl+a ]` to leave this mode |
| `Ctrl+a ]` | paste buffer	Supports pasting between windows |
| `Ctrl+a >` | write paste buffer to file useful for copying between screens |
| `Ctrl+a <` | read paste buffer from file	useful for pasting between screens |	 
| `Ctrl+a ?` | show key bindings/command names Note unbound commands only in man page |
| `Ctrl+a :` | goto screen command prompt up shows last command entered |

![screen快捷键](../../../img/develop/shell/utilities/Screen-Terminal-Multiplexer-Commands.png)

# screen常用命令

`screen -t name` 命令在创建窗口时指定窗口名称

`screen -L` 命令把每个窗口的输出记录在日志中。每个窗口有自己的日志文件，文件名通常是 `~/screenlog.n`，其中的 `n` 是窗口列表中显示的窗口编号。（这个`-L`参数不需要指定文件名）

最有用的组合键包括：按 `Ctrl-a`，然后按 `0`（数字零）到 `9` 立即切换到特定的窗口；按 `Ctrl-a`，然后按 `C`（大写的字母 C，代表 “Clear”）清除一个窗口的内容；按 `Ctrl-a`，然后按 `H` 启用或禁用日志记录；按 Ctrl-a，然后按 Ctrl-a 在当前窗口和前一个窗口之间来回切换；按 `Ctrl-a`，然后按 `Ctrl-\`（反斜杠）杀死所有窗口并终止当前的 Screen 会话

Screen 会话的连接，可以用 `screen -p ID` 命令重新连接特定的窗口，其中的 `ID` 是一个数字或名称

    screen -r -p ghost

**多用户模式连接其它窗口**

    screen -x -r sharing -p one

> 这里 `-x` 表示多用户模式，`-p one`表示连接到另外一个名字叫`one`的窗口，这样两个窗口就连接在一起，并且可以看到共同的输入输出。

**屏幕分隔**

左右分割屏幕快捷键是`Ctrl-a |`，上下分割屏幕快捷键是`Ctro-a S`

![screen屏幕分隔](/img/os/utility/Gnuscreen.png)

去除split出来的`region`使用快捷键`Ctrl-a X`

分屏以后，可以使用`Ctrl-a <tab>`在各个区块间切换，不过，分割屏幕之后，切换到新的屏幕，需要使用`Ctrl-a c`来创建会话。

**C/P模式和操作**

使用快捷键`Ctrl-a <Esc>`或者`Ctrl-a [`可以进入copy/paste模式，这个模式下可以像在vi中一样移动光标，并可以使用空格键设置标记。其实在这个模式下有很多类似vi的操作，譬如使用/进行搜索，使用y快速标记一行，使用w快速标记一个单词等。关于C/P模式下的高级操作，其文档的这一部分有比较详细的说明。

一般情况下，可以移动光标到指定位置，按下空格设置一个开头标记，然后移动光标到结尾位置，按下空格设置第二个标记，同时会将两个标记之间的部分储存在copy/paste buffer中，并退出copy/paste模式。在正常模式下，可以使用快捷键`Ctrl-a ]`将储存在buffer中的内容粘贴到当前窗口。

# ssh远程后台在screen中执行脚本

> 这个功能是screen的杀手锏，提供了远程在后台执行脚本的能力。并且可以随时连接到screen进行维护

参考[how to run a command in background using ssh and detach the session](http://stackoverflow.com/questions/1628204/how-to-run-a-command-in-background-using-ssh-and-detach-the-session)

    screen -S restart_network -dm /etc/init.d/network restart

这样 `-dm` 命令可以执行shell时断开，以便后续再连接访问。

```bash
	   -d|-D [pid.tty.host]
            does not start screen, but detaches the elsewhere running screen session. It has the same  effect  as  typing
            "C-a  d" from screen’s controlling terminal. -D is the equivalent to the power detach key.  If no session can
            be detached, this option is ignored. In combination with the  -r/-R  option  more  powerful  effects  can  be
            achieved:	        
		-m   causes screen to ignore the $STY environment variable.  With  "screen  -m"  creation  of  a  new  session  is
            enforced, regardless whether screen is called from within another screen session or not. This flag has a spe-
            cial meaning in connection with the ‘-d’ option:        
		-d -m   Start screen in "detached" mode. This creates a new session but doesn’t attach to it. This is  useful  for
        system startup scripts.
```

> 使用`screen`的好处是某些需要使用tty的工具可以正常执行
>
> 注意`一定要正常能够执行的shell脚本`，否则会直接结束，并且返回值还是`0`，就不知道是否正确执行脚本了

使用`nohup`也可以实现

    ssh remoteserver 'nohup /path/to/script `</dev/null` >nohup.out 2>&1 &'

但是nohup方式不利于再次连接终端进行检查。

一个案例：需要在服务器上通过`strace`工具来跟踪程序`example_program`

```bash
pssh -ih nc_list 'screen -S strace_example_program -d -m sudo strace -o example_program.strace -p `pgrep example_program`'
```

# Cannot open your terminal

当时用sudo切换到普通用户身份执行`screen`指令时，会遇到报错

```bash
Cannot open your terminal '/dev/pts/135' - please check.
```

这个报错原因是因为你通过其他用户身份登录到系统终端中，然后执行了`sudo su`指令，此时`tty`终端设备并没有随着身份切换而改变，所以切换身份后用户无法访问终端设备文件。

用以下方法可以验证：

* 首先登录到系统中，执行`tty`命令可以查看到终端设备名：

```
#tty
/dev/pts/135
```

* 然后切换身份到`admin`用户再次执行`tty`命令则看到终端设备名不变，依然是`/dev/pts/135`

```
#su - admin
-bash: ulimit: open files: cannot modify limit: Operation not permitted

$tty
/dev/pts/135
```

解决方法有以下几种：

* 退出系统，直接用需要使用`screen`指令的用户身份登录系统，这样使用`screen`命令就不会有无法访问`/dev/pts/XXX`权限问题
* 直接修改设备权限，例如`chmod 777 /dev/pts/135`，但是这个方法存在安全隐患，不建议使用
* 推荐的解决方法：使用`script /dev/null`指令，这样用户的`tty`设备就会切换到其他终端设备。

案例：

```
$script /dev/null
Script started, file is /dev/null
bash: ulimit: open files: cannot modify limit: Operation not permitted

$tty
/dev/pts/189
```

此时使用`screen`指令就不会存在权限错误问题。

# 参考

* [对话 UNIX: 使用 Screen 创建并管理多个 shell](http://www.ibm.com/developerworks/cn/aix/library/au-gnu_screen/index.html)
* [linux screen 命令详解](http://www.cnblogs.com/mchina/archive/2013/01/30/2880680.html)
* [WikiPedia: GNU Screen](https://en.wikipedia.org/wiki/GNU_Screen)
* [linux 技巧：使用 screen 管理你的远程会话](https://www.ibm.com/developerworks/cn/linux/l-cn-screen/)
* [The Antidesktop](http://freecode.com/articles/the-antidesktop) 一个有趣的桌面替代方案
* [screen key](http://www.pixelbeat.org/lkdb/screen.html) - 这篇文档常用快捷键
* [解决Screen出现Cannot open your terminal ‘/dev/pts/0’问题](https://blog.ttionya.com/article-1318.html) 和 [Solve screen error "Cannot open your terminal '/dev/pts/0' - please check"](https://makandracards.com/makandra/2533-solve-screen-error-cannot-open-your-terminal-dev-pts-0-please-check) 提供了解决`Cannot open your terminal '/dev/pts/0'`报错的方法
* [GNU Screen splitting](https://tomlee.co/2011/10/gnu-screen-splitting/)
* [How to Split Terminal Screen in Linux Ubuntu 14.04](http://sourcedigit.com/12480-split-terminal-screen-linux-ubuntu-14-04/) 这篇文章详细介绍了tmux和screen分割屏幕的操作方法，可以参考使用
* [How to re-order windows, change the scroll shortcut, and modify the status bar contents in GNU Screen?](https://serverfault.com/questions/244294/how-to-re-order-windows-change-the-scroll-shortcut-and-modify-the-status-bar-c/282279)
