#!/bin/bash

# 一键管理和配置 dnsmasq 脚本
# 请确保使用 sudo 或 root 权限运行此脚本

# 脚本版本和更新时间
VERSION="V0.1"
LAST_UPDATED=$(date +"%Y-%m-%d")

# 指定配置文件的下载地址
CONFIG_URL="https://raw.githubusercontent.com/Jimmyzxk/DNS-Alice-Unlock/refs/heads/main/dnsmasq.conf"
CONFIG_FILE="/etc/dnsmasq.conf"
SCRIPT_NAME="dns-unlock.sh"
AUTHOR="Jimmydada"

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[31m[错误] 请以 root 权限运行此脚本！\033[0m"
  exit 1
fi

# 检查系统是否为 Debian/Ubuntu
if ! grep -Ei 'debian|ubuntu' /etc/os-release > /dev/null; then
  echo -e "\033[31m[错误] 此脚本仅适用于 Debian 和 Ubuntu 系统！\033[0m"
  exit 1
fi

# 显示标题和备注
echo -e "\033[1;34m======================================\033[0m"
echo -e "\033[1;32m       一键配置 dnsmasq 脚本       \033[0m"
echo -e "\033[1;36m       版本：$VERSION       \033[0m"
echo -e "\033[1;36m       更新时间：$LAST_UPDATED       \033[0m"
echo -e "\033[1;36m       本脚本由 $AUTHOR 维护       \033[0m"
echo -e "\033[1;34m======================================\033[0m"
echo -e "\n"

# 显示菜单
echo -e "\033[1;33m请选择要执行的操作：\033[0m"
echo -e "\033[1;36m1.\033[0m \033[1;32m安装 dnsmasq\033[0m"
echo -e "\033[1;36m2.\033[0m \033[1;32m卸载 dnsmasq\033[0m"
echo -e "\033[1;36m3.\033[0m \033[1;32m一键更新 dnsmasq 配置文件\033[0m"
echo -e "\033[1;36m4.\033[0m \033[1;32m解锁 /etc/resolv.conf 文件\033[0m"
echo -e "\033[1;36m5.\033[0m \033[1;32m锁定 /etc/resolv.conf 文件\033[0m"
echo -e "\033[1;36m6.\033[0m \033[1;32m恢复原始 /etc/resolv.conf.bak 文件\033[0m"
echo -e "\033[1;36m7.\033[0m \033[1;32m检测流媒体解锁支持情况\033[0m"
echo -e "\033[1;36m8.\033[0m \033[1;32m检查端口 53 是否被占用\033[0m"
echo -e "\033[1;36m9.\033[0m \033[1;32m卸载本脚本并删除本地文件\033[0m"
echo -e "\n\033[1;33m请输入数字 (1-9):\033[0m"
read choice

case $choice in
1)
  # 安装 dnsmasq
  echo -e "\033[1;34m正在安装 dnsmasq...\033[0m"
  apt update -y && apt install -y dnsmasq curl
  if command -v dnsmasq &> /dev/null; then
    echo -e "\033[1;32mdnsmasq 安装成功！\033[0m"
  else
    echo -e "\033[31mdnsmasq 安装失败，请检查网络或软件源设置！\033[0m"
    exit 1
  fi

  # 下载 dnsmasq 配置文件
  echo -e "\033[1;34m下载并应用 dnsmasq 配置文件...\033[0m"
  if curl -o "$CONFIG_FILE" "$CONFIG_URL"; then
    echo -e "\033[1;32m配置文件下载成功！\033[0m"
  else
    echo -e "\033[31m配置文件下载失败，请检查网络连接或 URL 是否正确！\033[0m"
    exit 1
  fi

  # 备份并配置 /etc/resolv.conf
  echo -e "\033[1;34m备份并配置 /etc/resolv.conf 文件...\033[0m"
  if [ -f /etc/resolv.conf ]; then
    mv /etc/resolv.conf /etc/resolv.conf.bak
    rm -f /etc/resolv.conf
  fi

  echo -e "\033[1;34m创建新的 /etc/resolv.conf 文件，并设置 nameserver 为 127.0.0.1...\033[0m"
  echo "nameserver 127.0.0.1" > /etc/resolv.conf

  echo -e "\033[1;34m锁定 /etc/resolv.conf 文件，防止被修改...\033[0m"
  chattr +i /etc/resolv.conf
  echo -e "\033[1;32m/etc/resolv.conf 文件已成功更新并锁定！\033[0m"

  # 重启 dnsmasq 服务
  echo -e "\033[1;34m重启 dnsmasq 服务...\033[0m"
  systemctl restart dnsmasq

  # 检查服务状态
  if systemctl is-active --quiet dnsmasq; then
    echo -e "\033[1;32mdnsmasq 服务已成功重新启动！\033[0m"
  else
    echo -e "\033[31mdnsmasq 服务启动失败，请检查配置文件是否正确！\033[0m"
    exit 1
  fi
  ;;

2)
  # 卸载 dnsmasq
  echo -e "\033[1;34m正在卸载 dnsmasq...\033[0m"
  apt remove -y dnsmasq
  if ! command -v dnsmasq &> /dev/null; then
    echo -e "\033[1;32mdnsmasq 已成功卸载！\033[0m"
  else
    echo -e "\033[31mdnsmasq 卸载失败，请手动检查！\033[0m"
    exit 1
  fi
  ;;

3)
  # 更新 dnsmasq 配置文件
  echo -e "\033[1;34m备份原有的 dnsmasq 配置文件...\033[0m"
  if [ -f "$CONFIG_FILE" ]; then
    mv "$CONFIG_FILE" "${CONFIG_FILE}.bak"
  fi

  echo -e "\033[1;34m从远程下载新的配置文件...\033[0m"
  if curl -o "$CONFIG_FILE" "$CONFIG_URL"; then
    echo -e "\033[1;32m配置文件更新成功！\033[0m"
  else
    echo -e "\033[31m配置文件下载失败，请检查网络连接或 URL 是否正确！\033[0m"
    exit 1
  fi

  # 重启 dnsmasq 服务
  echo -e "\033[1;34m重启 dnsmasq 服务...\033[0m"
  systemctl restart dnsmasq

  # 检查服务状态
  if systemctl is-active --quiet dnsmasq; then
    echo -e "\033[1;32mdnsmasq 服务已成功重新启动！\033[0m"
  else
    echo -e "\033[31mdnsmasq 服务启动失败，请检查配置文件是否正确！\033[0m"
    exit 1
  fi
  ;;

4)
  # 解锁 /etc/resolv.conf
  echo -e "\033[1;34m解锁 /etc/resolv.conf 文件...\033[0m"
  chattr -i /etc/resolv.conf
  echo -e "\033[1;32m/etc/resolv.conf 文件已解锁！\033[0m"
  ;;

5)
  # 锁定 /etc/resolv.conf
  echo -e "\033[1;34m锁定 /etc/resolv.conf 文件...\033[0m"
  chattr +i /etc/resolv.conf
  echo -e "\033[1;32m/etc/resolv.conf 文件已锁定！\033[0m"
  ;;

6)
  # 恢复 /etc/resolv.conf.bak
  echo -e "\033[1;34m恢复 /etc/resolv.conf 文件...\033[0m"
  if [ -f /etc/resolv.conf.bak ]; then
    chattr -i /etc/resolv.conf 2>/dev/null
    mv /etc/resolv.conf.bak /etc/resolv.conf
    chattr +i /etc/resolv.conf
    echo -e "\033[1;32m/etc/resolv.conf 文件已从备份恢复并锁定！\033[0m"
  else
    echo -e "\033[31m备份文件 /etc/resolv.conf.bak 不存在，无法恢复！\033[0m"
  fi
  ;;

7)
  # 检测流媒体解锁支持情况
  echo -e "\033[1;34m检测流媒体解锁支持情况...\033[0m"
  bash <(curl -sL IP.Check.Place)
  if [ $? -eq 0 ]; then
    echo -e "\033[1;32m流媒体解锁检测完成！\033[0m"
  else
    echo -e "\033[31m流媒体解锁检测失败，请检查网络连接或脚本 URL！\033[0m"
  fi
  ;;

8)
  # 检查端口 53 是否被占用
  echo -e "\033[1;34m检查端口 53 是否被占用...\033[0m"
  PORT_IN_USE=$(sudo netstat -tuln | grep ':53')
  if [ -n "$PORT_IN_USE" ]; then
    echo -e "\033[31m端口 53 已被占用，检查是否为 systemd-resolved...\033[0m"

    SYSTEMD_RESOLVED=$(ps aux | grep 'systemd-resolved' | grep -v 'grep')

    if [ -n "$SYSTEMD_RESOLVED" ]; then
      echo -e "\033[31m发现 systemd-resolved 占用 53 端口，正在停止并禁用 systemd-resolved 服务...\033[0m"
      sudo systemctl stop systemd-resolved
      sudo systemctl disable systemd-resolved

      sudo rm -f /etc/resolv.conf
      echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf > /dev/null
      echo -e "\033[1;32m/etc/resolv.conf 文件已更新为指向本地 DNS 解析。\033[0m"
    else
      echo -e "\033[31m系统未检测到 systemd-resolved 占用 53 端口，可能由其他进程占用。\033[0m"
    fi
  else
    echo -e "\033[1;32m端口 53 未被占用，可以正常启动 dnsmasq。\033[0m"
  fi
  ;;

9)
  # 卸载本脚本并删除本地文件
  echo -e "\033[1;34m正在卸载本脚本并删除本地文件...\033[0m"
  if [ -f "$SCRIPT_NAME" ]; then
    rm -f "$SCRIPT_NAME"
    echo -e "\033[1;32m脚本文件已删除！\033[0m"
  else
    echo -e "\033[31m脚本文件不存在，无法删除！\033[0m"
  fi
  ;;

*)
  echo -e "\033[31m无效选项，请重新运行脚本并选择 1-9。\033[0m"
  exit 1
  ;;
esac

echo -e "\033[1;34m操作完成！\033[0m"
