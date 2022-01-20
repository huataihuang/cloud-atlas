# RSA/DSA认证

SSH以及`OpenSSH`可以在远程服务器上运行sshd服务进程，加密客户端和服务器之间的数据通讯，不仅可以加密数据流，确保数据流的完整性，以及使用了专门的算法进行认证。

OpenSSH的RSA和DSA的认证协议的基础是使用一对专门生成的密钥，分别叫做`私有密钥`和`公用密钥`。

## RSA/DSA密钥工作原理

公用密钥用来对消息进行加密，只有配对的私有密钥能够对该消息进行解密。初始配置RSA，需要生成一对密钥。将公用密钥复制到远程服务器上的正确位置。由于公用密钥只能用于消息加密，所以不太需要担心被落入他人之手。一旦公用密钥被复制到远程服务器的专门文件（`~/.ssh/authorized_keys`），就能使用RSA认证登陆到远程服务器。

登陆时，远程服务器sshd首先生成一个随机数，然后用登陆用户帐号中的公用密钥进行加密后发送给客户端。由于客户端有配对的私有密钥，则可以对这个随机数进行解密然后再发回给服务器。这样服务器能够验证是授权用户登陆。

## 密钥使用注意事项

* 只需要生成一对密钥就可以，把公用密钥复制到需要访问的服务器上就能够实现对服务器的授权访问。
* 专用密钥不应落入他人之手。因为拥有专用密钥就会被授权完全相同的权限。为加上保护措施，应该在使用 `ssh-keygen` 创建公用/专用密钥对的时候，输入密钥密码来保护密钥。这样不知道密钥密码的人即使拿到了密钥也不能使用。虽然这样导致使用密钥的时候需要输入密码，但实际上可以通过配合使用`ssh-agent`来实现只输入一次密钥密码就可以缓存并重复调用密钥。

# RSA密钥

使用 `ssh-keygen` 命令生成密钥对

```bash
ssh-keygen -t rsa
```

> 在创建密钥对的时候，会要求输入密钥的保护密码。虽然可以连续输入两次回车去除密码保护，但是降低了安全性。

默认情况下会在用户目录下的 `.ssh` 目录下生成私有密钥 `id_rsa` 和 公用密钥 `id_rsa.pub`。

## RSA公用密钥安装

将公用RSA密钥复制到需要以某个身份登陆的用户目录下的 `.ssh` 目录下，以下为服务器上的用户帐号 `jerry` (注意在创建账户时指定组，并加上注释`-c`)
* 创建 jerry 帐号

```bash
useradd -g wheel -u 1919 -d /home/jerry -m -c "I'am jerry, a mouse." jerry
```

* 将公共密钥复制到服务器上jerry用户的`.ssh`目录下，改名为 `authorized_keys`，同时使用如下命令确保`.ssh`目录属性和`authorized_keys`文件属性正确

```bash
chown -R jerry:wheel .ssh
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
```

## 检查本地主机.ssh的属性

本地 `.ssh` 目录和 `id_rsa` 文件权限要求：

* `.ssh` 目录的属性是 ''700''
* `.ssh` 目录下的 `id_rsa` 私有密钥的属性是 `600`
* `.ssh` 目录下的 `id_rsa.pub` 公用密钥的属性是 `644`

远程 `.ssh` 目录和 `authorized_keys` 文件权限要求：

* `.ssh` 目录的属性是 `700`
* .ssh` 目录下的 `authorized_keys` 私有密钥的属性是 `600`

> 密钥属性和`.ssh`目录属性是密钥认证成功的关键：`.ssh` 和 密钥对的属性必须严格按照以上要求设置，否则ssh会拒绝使用密钥认证。

## 关闭密码认证，开启密钥认证

`/etc/ssh/sshd_config` 中有

```bash
#PermitEmptyPasswords no
```

也就是默认拒绝空密码。建议不要修改这个配置，而是设置一个复杂密码（反正也能够使用密钥认证）。但更好的方法是在sshd配置中`禁止密码认证`，只允许密钥认证以防范密码暴力破解：

将

```bash
#PasswordAuthentication yes
```

改为

```bash
PasswordAuthentication no
```

另外sshd默认配置有以下（允许RSA密钥认证）

```bash
#RSAAuthentication yes
#PubkeyAuthentication yes
#AuthorizedKeysFile     .ssh/authorized_keys
```

> 在`sshd_config`配置中，默认的`#`开头的配置项即为软件的默认隐含配置，如需特定设置，请明确配置该项。

# ssh agent

`ssh-agent`是OpenSSH发布包中的一个针对RSA和DSA密钥设计的特殊程序。`ssh-agent`是一个长时间运行的守护进程（daemon），用途是对解密的专用密钥进行高速缓存。

ssh内建和`ssh-agent`通讯的机制，这样ssh不需要每次连接都提示保护密码才能使用解密的专用密钥。对于ssh-agent，只要使用 `ssh-add` 命令把专用密钥添加到`ssh-agent`的高速缓存中。当使用过 `ssh-add` 之后，ssh将从`ssh-agent`获取专用密钥，就不需要每次提示必须输入密钥保护密码才能使用专用密钥了。

## 使用`ssh-agent`

`ssh-agent`在启用之前会输出一些提示信息

```bash
$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-XX4LkMJS/agent.26916; export SSH_AUTH_SOCK;
SSH_AGENT_PID=26917; export SSH_AGENT_PID;
echo Agent pid 26917;
```

但是这只是表示打印输出。要让`ssh-agent`在shell后台运行，使用

```bash
eval `ssh-agent`
```

注意使用反引号。这样ssh-agent在整个登陆会话期间所有新进程都可以使用。

启动`ssh-agent`的最佳方式是将上述命令添加到 `~/.bash_profile` 中，这样登陆shell的所有启动程序都能够使用。尤其重要的环境变量是 `SSH_AUTH_SOCK`。`SSH_AUTH_SOCK` 包含有 ssh 和 scp 可以用来同 `ssh-agent` 建立对话的 UNIX 域套接字的路径。

opensolaris环境中，进入操作系统可以看到 ssh-agent 已经启动。

启动完`ssh-agent`后，高速缓存中是空的，并没有解密的专用密钥。在能够使用`ssh-agent`之前，首先需要使用`ssh-add`命令把自己的专用密钥添加到`ssh-agent`的高速缓存中。

注意，由于前面生成密钥的时候使用了保护密码，所以在使用`ssh-add`的时候会提示输入保护密码。

```bash
$ ssh-add
Enter passphrase for /home/jerry/.ssh/id_rsa: 
Identity added: /export/home/jerry/.ssh/id_rsa (/export/home/jerry/.ssh/id_rsa)
```

这个是默认加载 `~/.ssh/id_rsa` 也可以指定加载某个key

```bash
ssh-add ~/my_key
```

## 使用`ssh-agent`的不足

* 当在图形环境中（也就是多个用户），每个登陆会话都会启动一个新的ssh-agent副本，这样每次都需要使用`ssh-add`向每个新的`ssh-agent`副本添加专用密钥。
* `ssh-agent`的缺省设置和`cron`作业不兼容，由于`cron`作业是`cron`进程启动的，这些作业无法从它们的环境中继承`SSH_AUTH_SOCK`变量，因此也无法知道`ssh-agent`进程正在运行以及如何同它联系。

## shell环境解决ssh-agent对会话的要求

> 参考OReilly出版 《Linux Server Hacks 卷1》

如果不想为每个打开的shell窗口都运行一个代理（或者在这些窗口之间复制和粘贴环境设置），可以在 `~/.profile` 中加入如下代码

```bash
if [ -f ~/.agent.env ]; then
  . ~/.agent.env -s > /dev/null

  if ! kill -0 $SSH_AGENT_PID > /dev/null 2>&1; then
    echo
    echo "Stale agent file found.  Spawning new agent..."
    eval `ssh-agent -s | tee ~/.agent.env`
    ssh-add
  fi
else
  echo "Starting ssh-agent..."
  eval `ssh-agent -s | tee ~/.agent.env`
  ssh-add
fi
```

以上脚本会维护一个 `~/.agent.env`文件以及指向当前运行的`ssh-agent`的环境。如果代理失败，将会自动打开一个新的终端窗口并添加密钥，所有后续的终端窗口都可以共享这个窗口。

# 使用指定ssh key

有时候我们访问不同的SSH服务器需要使用不同的ssh密钥对，可以通过以下命令方法来指定私钥:

```bash
ssh -o "IdentitiesOnly=yes" -i <private key filename> <hostname>
```

这个方法适合存储不同的ssh私钥登陆不同的系统

# 忽略服务器key验证

在使用脚本命令ssh登陆到服务器执行命令，如果是第一次访问服务器(例如需要扫描大量服务器)，默认ssh会通过交互方式让你确认接受服务器key。这对于批量脚本非常不方便，解决方法是默认接受服务器key不验证。

```bash
ssh -o StrictHostKeyChecking=no username@hostname
```

这样服务器的key就会自动接受存入 `~/.ssh/known_hosts` 

另外一种情况是用户目录不能修改，例如不能保存和修改 `~/.ssh/known_hosts` ，则再加上 `UserKnownHostsFile` 参数指定另一个文件(例如指向null文件):

```bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no username@hostname
```

# 参考

* [OpenSSH 密钥管理，第 1 部分](http://www.ibm.com/developerworks/cn/linux/security/openssh/part1/index.html)
* [OpenSSH 密钥管理，第 2 部分](http://www.ibm.com/developerworks/cn/linux/security/openssh/part2/index.html)
* [OpenSSH 密钥管理，第 3 部分](http://www.ibm.com/developerworks/cn/linux/security/openssh/part3/index.html)
* [An Illustrated Guide to SSH Agent Forwarding](http://www.unixwiz.net/techtips/ssh-agent-forwarding.html)
* [SSH Agent](http://en.wikipedia.org/wiki/Ssh-agent)
* [SSH](http://mah.everybody.org/docs/ssh)
* [Howto force ssh to use a specific private key?](https://superuser.com/questions/772660/howto-force-ssh-to-use-a-specific-private-key)
* [HowTo Avoid Host Key Verification When Using SSH](https://community.mellanox.com/s/article/howto-avoid-host-key-verification-when-using-ssh)