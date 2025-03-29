#!/bin/env bash

# 设置代理(可选)
#git config --global http.proxy http://192.168.10.106:3128

# 安装brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask iterm2

# 编译you-complete-vim需要cmake和macvim
brew install cmake macvim

# tmux提供iterm多终端增强
brew install tmux

# oh-my-zsh 增强macOS zsh
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Vundle管理vim插件
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# clone Danielshow 提供的Boxsetting
git clone https://github.com/Danielshow/BoxSetting
cd BoxSetting
# 复制配置文件
cp tmux.conf ~/.tmux.conf
cp vimrc ~/.vimrc
cp zshrc ~/.zshrc

# 安装nvm再安装node，使用nvm管理node版本
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm instal node

# 安装spaceship-prompt
npm install -g spaceship-prompt

# 这里用户名是 huatai ，请修改成你的名字
ZSH_CUSTOM=/Users/huatai/.oh-my-zsh
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# 安装spaceship-prompt字体
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts

# 编译youcompleteme可能需要先升级一次watchdog模块，我是在 python virtualenv 环境中完成
pip install -U watchdog

# 修改 ~/.zshrc注释掉一些还没有安装的插件，确保启动终端不再报错

# 打开 ``vim`` ，执行命 :PluginInstall
