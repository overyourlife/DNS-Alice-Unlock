#!/bin/bash

# 一键安装和配置 dnsmasq 脚本
# 请确保使用 sudo 或 root 权限运行此脚本

# 指定配置文件的下载地址
CONFIG_URL="https://raw.githubusercontent.com/Jimmyzxk/DNS-Alice-Unlock/refs/heads/main/dnsmasq.conf"
CONFIG_FILE="/etc/dnsmasq.conf"

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本！"
  exit 1
fi

# 安装 dnsmasq
echo "正在安装 dnsmasq..."
apt update && apt install -y dnsmasq curl

# 检查安装是否成功
if ! command -v dnsmasq &> /dev/null; then
  echo "dnsmasq 安装失败，请检查网络或软件源设置！"
  exit 1
fi

# 备份原有配置文件
echo "备份原有的 dnsmasq 配置文件..."
if [ -f "$CONFIG_FILE" ]; then
  mv "$CONFIG_FILE" "${CONFIG_FILE}.bak"
fi

# 下载新的配置文件
echo "从远程下载配置文件..."
if ! curl -o "$CONFIG_FILE" "$CONFIG_URL"; then
  echo "配置文件下载失败，请检查网络连接或 URL 是否正确！"
  exit 1
fi

# 备份并强制删除 /etc/resolv.conf
echo "备份原有的 /etc/resolv.conf 文件..."
if [ -f /etc/resolv.conf ]; then
  mv /etc/resolv.conf /etc/resolv.conf.bak
  echo "删除原有的 /etc/resolv.conf 文件..."
  rm -f /etc/resolv.conf
fi

# 创建新的 /etc/resolv.conf 文件
echo "创建新的 /etc/resolv.conf 文件，并设置 nameserver 为 127.0.0.1..."
echo "nameserver 127.0.0.1" > /etc/resolv.conf

# 锁定 /etc/resolv.conf 文件
echo "锁定 /etc/resolv.conf 文件，防止被修改..."
chattr +i /etc/resolv.conf

# 重启 dnsmasq 服务
echo "重启 dnsmasq 服务..."
systemctl restart dnsmasq

# 检查 dnsmasq 服务状态
if systemctl is-active --quiet dnsmasq; then
  echo "dnsmasq 已成功安装并配置完成！"
else
  echo "dnsmasq 启动失败，请检查配置文件是否正确！"
  exit 1
fi

echo "所有操作已完成！原始的 /etc/resolv.conf 文件已备份为 resolv.conf.bak，新文件已锁定。"
