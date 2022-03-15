#!/bin/env bash

# 设置代理(可选)
#git config --global http.proxy http://192.168.10.106:3128

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask iterm2
brew install vim
