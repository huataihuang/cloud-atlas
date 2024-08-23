...
USER admin

# ruby program: rvm install ruby in $HOME
RUN gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable
# /bin/sh 不支持source，需要使用 . 
# 每个RUN都是一个容器，所以为了继承环境变量来运行多个命令，将这些命令写成一行RUN
# rvm需要使用BASH，所以最终改成 bash -c 'xxx && yyy && zzz'
RUN bash -c 'source /home/admin/.rvm/scripts/rvm && rvm install 3.3.4 && gem install rails'

# python program: virtualenv
RUN bash -c 'cd /home/admin && python3 -m venv venv3'
RUN bash -c 'source /home/admin/venv3/bin/activate && pip install sphinx && pip install sphinx_rtd_theme && pip install sphinxnotes-strike'
RUN bash -c 'source /home/admin/venv3/bin/activate && pip install sphinxcontrib-video && pip install sphinxcontrib-youtube'
