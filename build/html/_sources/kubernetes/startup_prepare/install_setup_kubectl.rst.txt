.. _install_setup_kubectl:

==================
安装和设置kubectl
==================

在安装并运行了minikube之后，我们需要在主机上安装kubectl，以便能够管理kubernetes集群（这里即为minikube单机）。

安装kubectl
===============

在Linux平台使用curl安装kubectl执行程序
----------------------------------------

- 通过命令行可以直接下载64位X86 Linux版本执行程序::

   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

- 验证(可选)::

   curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
   echo "$(<kubectl.sha256) kubectl" | sha256sum --check

- 执行安装::

   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

- 验证::

   kubectl version

CentOS, RHEL, Fedora 安装kubectl
----------------------------------

- 通过官方软件仓库安装kubectl::

   cat <<EOF > /etc/yum.repos.d/kubernetes.repo
   [kubernetes]
   name=Kubernetes
   baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
   EOF
   yum install -y kubectl

.. note::

   通过Google官方软件库安装需要 :ref:`openconnect_vpn`

Ubuntu, Debian 安装kubectl
-----------------------------

- 通过官方软件仓库安装kubectl::

   sudo apt update && sudo apt install -y apt-transport-https gnupg2 curl
   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
   echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
   sudo apt update
   sudo apt install -y kubectl

.. note::

   由于我在 :ref:`studio` 环境采用了Ubuntu，并且 :ref:`kubenetes_in_studio` 为了能够提高运行效率，我 :ref:`install_run_minikube` 直接在物理主机运行 minikube 来学习和验证kubernetes技术。目前，采用通过官方软件仓库来安装kubectl。

.. note::

   Ubuntu/Debian有不同版本代号，请参考 https://packages.cloud.google.com/apt/dists 选择适合你的发行版，例如，我在 :ref:`pi_400` 上使用的是32位ARM的Raspberry Pi OS，当前是 ``debian 10.8`` 版本代码是 ``buster`` ，对应的Ubuntu版本是 ``18.04 bionic`` 到 ``19.10 eoan`` ，取Ubuntu LTS版本代号 ``bionic`` ::

      echo "deb https://apt.kubernetes.io/ kubernetes-bionic main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

   不过，也可能当前Google并没有针对这个Ubuntu/Debian发布对应版本，例如，目前还只能使用 ``kubernetes-xenial``

macOS 安装kubectl
-------------------

- 下载最新版本::

   curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl

- 设置可执行权限::

   chmod +x ./kubectl

- 移动到路径中::

   sudo mv ./kubectl /usr/local/bin/kubectl

- 检查程序::

   kubectl version

配置kubectl
==============

为了能够使kubectl发现并访问Kubernetes集群，需要使用 `kubeconfig <https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/>`_ 配置文件，这个配置文件是通过使用 ``kube-up.sh`` 脚本创建集群自动生成，或者是部署minikube集群生成的。

如果要访问多个kubernetes集群，请参考 `Shareing Cluster Access document <https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/>`_ 。我将在后续撰写相关实践文档。

默认的kubectl配置文件位于 ``~/.kube/config`` ::

   apiVersion: v1
   clusters:
   - cluster:
       certificate-authority: /home/huatai/.minikube/ca.crt
       server: https://192.168.101.81:8443
     name: minikube
   - cluster:
       certificate-authority: /home/huatai/.minikube/ca.crt
       server: https://192.168.101.81:8443
     name: xminikube
   contexts:
   - context:
       cluster: minikube
       user: minikube
     name: minikube
   - context:
       cluster: xminikube
       user: xminikube
     name: xminikube
   current-context: xminikube
   kind: Config
   preferences: {}
   users:
   - name: minikube
     user:
       client-certificate: /home/huatai/.minikube/client.crt
       client-key: /home/huatai/.minikube/client.key
   - name: xminikube
     user:
       client-certificate: /home/huatai/.minikube/client.crt
       client-key: /home/huatai/.minikube/client.key

.. note::

   根据你采用的minikube安装方式不同，这里默认 ``~/.kube/config`` 指向的服务器IP地址会不同。我这里采用了裸物理机运行minikube并且指定集群名字是 ``xminikube`` 。这里服务器的IP地址是从 :ref:`openconnect_vpn` 环境获得的tun接口的IP，因为我的测试环境启动了VPN连接到外部网络。

- 现在我们来验证集群状态::

   kubectl cluster-info

显示输出::

   Kubernetes master is running at https://192.168.101.81:8443
   KubeDNS is running at https://192.168.101.81:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

这表明之前安装的minikube已经正常工作了。

更详细的集群信息可以通过如下命令显示::

   kubectl cluster-info dump

激活shell自动补全
====================

kubectl包含了一个自动补全命令功能，可以大大提高工作效率。

.. note::

   CentOS可能需要先安装 ``bash-completion`` 软件包::

      yum install bash-completion -y

   Ubuntu则默认已经安装了 ``bash-completion``

为了能够在当前shell中使用kubectl的自动补全功能，请执行 ``source <(kubectl completion bash)``

也可以加入shell环境变量，这样登陆就可以使用::

   echo "source <(kubectl completion bash)" >> ~/.bashrc

参考
==========

- `Install and Set Up kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_

