# name the portage image
FROM gentoo/portage:latest as portage

# based on stage3 image
FROM gentoo/stage3:latest

# copy the entire portage volume in
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

# config make.conf:  use chinese mirror
RUN echo 'GENTOO_MIRRORS="http://mirrors.aliyun.com/gentoo http://distfiles.gentoo.org http://www.ibiblio.org/pub/Linux/distributions/gentoo"' >> /etc/portage/make.conf
RUN sed -i 's/\-O2 \-pipe/\-march=native \-O2 \-pipe/g' /etc/portage/make.conf

# config gentoo.conf: use chinese repos
RUN mkdir /etc/portage/repos.conf
RUN cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
RUN sed -i 's/rsync.gentoo.org/rsync.cn.gentoo.org/g' /etc/portage/repos.conf/gentoo.conf

# timezone
RUN echo "Asia/Shanghai" > /etc/timezone
RUN emerge --config sys-libs/timezone-data

# sync
RUN emaint -a sync

# USE for cpu
RUN emerge -qv app-portage/cpuid2cpuflags
RUN echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

# upgrade: emerge quiet (-q)
RUN emerge -qvuDN @world

# continue with image build ...
RUN emerge -qv sys-apps/openrc
RUN emerge -qv sys-apps/mlocate
RUN emerge -qv net-dns/bind-tools
RUN emerge -qv net-analyzer/netcat
RUN emerge -qv app-editors/vim
RUN emerge -qv app-admin/sudo

# sshd
RUN rc-update add sshd default

# add account "admin" and give sudo privilege
RUN groupadd -g 1001 admin
RUN useradd -g 1001 -u 1001 -d /home/admin -m admin
RUN usermod -aG wheel admin
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# Add ssh public key for login
RUN mkdir -p /home/admin/.ssh
COPY authorized_keys /home/admin/.ssh/authorized_keys
RUN chown -R admin:admin /home/admin/.ssh
RUN chmod 600 /home/admin/.ssh/authorized_keys
RUN chmod 700 /home/admin/.ssh

# 墙内RVM安装需要梯子，在Dockerfile中注入代理配置
#ENV HTTP_PROXY "http://192.168.6.200:3128"
#ENV HTTPS_PROXY "http://192.168.6.200:3128"
#ENV NO_PROXY "*.baidu.com,.taobao.com"

# Ruby Rails (master)
RUN gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s master --rails

# expose ssh/http/https AND some dev ports
EXPOSE 22
EXPOSE 80
EXPOSE 443
#EXPOSE 3000
#EXPOSE 8000

CMD ["/sbin/init"]
