#!/bin/bash

# 一键管理和配置 dnsmasq 脚本
# 请确保使用 sudo 或 root 权限运行此脚本

# 脚本版本和更新时间
VERSION="V_0.6.1"
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

# 公共函数：检查端口占用并释放
check_and_release_port() {
  local port=$1
  echo -e "\033[1;34m检查端口 $port 的占用情况...\033[0m"
  if lsof -i :$port | grep -q LISTEN; then
    echo -e "\033[31m端口 $port 被以下进程占用：\033[0m"
    lsof -i :$port
    echo -e "\033[33m尝试关闭相关进程...\033[0m"
    lsof -i :$port | awk 'NR>1 {print $2}' | xargs -r kill -9
    echo -e "\033[1;32m端口 $port 已释放。\033[0m"
  else
    echo -e "\033[1;32m端口 $port 未被占用。\033[0m"
  fi
}

# 公共函数：设置 resolv.conf 并锁定
set_and_lock_resolv_conf() {
  local nameserver=$1
  echo -e "\033[1;34m备份 /etc/resolv.conf 文件...\033[0m"
  cp /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null
  echo -e "\033[1;34m删除旧的 /etc/resolv.conf 并创建新文件...\033[0m"
  rm -f /etc/resolv.conf
  echo "nameserver $nameserver" > /etc/resolv.conf
  echo -e "\033[1;34m锁定 /etc/resolv.conf 文件...\033[0m"
  chattr +i /etc/resolv.conf
  echo -e "\033[1;32m操作成功！当前 nameserver 已设置为 $nameserver 并已锁定。\033[0m"
}

# 显示标题和备注
echo -e "\033[1;34m======================================\033[0m"
echo -e "\033[1;32m       一键配置 dnsmasq 分流脚本       \033[0m"
echo -e "\033[1;36m       版本：  $VERSION       \033[0m"
echo -e "\033[1;36m       更新时间：$LAST_UPDATED       \033[0m"
echo -e "\033[1;36m       本脚本由 $AUTHOR 维护       \033[0m"
echo -e "\033[1;34m======================================\033[0m"
echo -e "\n"

# 显示菜单
echo -e "\033[1;33m请选择要执行的操作：\033[0m"
echo -e "\033[1;36m1.\033[0m \033[1;32m安装并配置 dnsmasq 分流\033[0m"
echo -e "\033[1;36m2.\033[0m \033[1;32m卸载 dnsmasq 并恢复默认配置\033[0m"
echo -e "\033[1;36m3.\033[0m \033[1;32m更新 dnsmasq 配置文件\033[0m"
echo -e "\033[1;36m4.\033[0m \033[1;32m解锁 /etc/resolv.conf 文件\033[0m"
echo -e "\033[1;36m5.\033[0m \033[1;32m锁定 /etc/resolv.conf 文件\033[0m"
echo -e "\033[1;36m6.\033[0m \033[1;32m恢复原始 /etc/resolv.conf 配置\033[0m"
echo -e "\033[1;36m7.\033[0m \033[1;32m检测流媒体解锁支持情况\033[0m"
echo -e "\033[1;36m8.\033[0m \033[1;32m检查系统端口 53 占用情况\033[0m"
echo -e "\033[1;36m9.\033[0m \033[1;32m删除本脚本文件\033[0m"
echo -e "\033[1;36m10.\033[0m \033[1;32m一键更换 resolv.conf 中的 nameserver\033[0m"
echo -e "\n\033[1;33m请输入数字 (1-10):\033[0m"
read choice

case $choice in
1)
  # 安装并配置 dnsmasq
  echo "执行安装 dnsmasq 的相关操作..."
  
  # 安装 dnsmasq
  apt update && apt install -y dnsmasq
  if [ $? -ne 0 ]; then
    echo -e "\033[31m[错误] dnsmasq 安装失败，请检查系统环境！\033[0m"
    exit 1
  fi

  # 下载并更新配置文件
  echo -e "\033[1;34m下载并覆盖 dnsmasq 配置文件...\033[0m"
  curl -o $CONFIG_FILE $CONFIG_URL
  if [ $? -ne 0 ]; then
    echo -e "\033[31m[错误] 配置文件下载失败，请检查网络连接！\033[0m"
    exit 1
  fi
  echo -e "\033[1;32m配置文件已更新：$CONFIG_FILE\033[0m"

  # 检查端口 53 占用情况
  check_and_release_port 53

  # 备份并更新 /etc/resolv.conf
  set_and_lock_resolv_conf "127.0.0.1"

  # 重启 dnsmasq 服务
  echo -e "\033[1;34m重启 dnsmasq 服务...\033[0m"
  systemctl restart dnsmasq && systemctl enable dnsmasq
  if [ $? -eq 0 ]; then
    echo -e "\033[1;32mdnsmasq 服务已成功启动并启用开机自启！\033[0m"
  else
    echo -e "\033[31m[错误] dnsmasq 服务启动失败，请检查配置！\033[0m"
  fi
  ;;

2)
  # 卸载 dnsmasq 并恢复默认配置
  echo "执行卸载 dnsmasq 的相关操作..."
  apt-get purge -y dnsmasq
  systemctl disable --now dnsmasq
  rm -f $CONFIG_FILE
  echo -e "\033[1;32mdnsmasq 已成功卸载并恢复默认配置！\033[0m"
  ;;

3)
  # 更新 dnsmasq 配置文件
  echo "执行更新 dnsmasq 配置文件的相关操作..."
  curl -o $CONFIG_FILE $CONFIG_URL
  if [ $? -eq 0 ]; then
    echo -e "\033[1;32m配置文件已成功更新！\033[0m"
  else
    echo -e "\033[31m[错误] 配置文件更新失败！\033[0m"
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
  # 恢复原始 /etc/resolv.conf 配置
  echo -e "\033[1;34m恢复原始 /etc/resolv.conf 配置...\033[0m"
  if [ -f /etc/resolv.conf.bak ]; then
    mv /etc/resolv.conf.bak /etc/resolv.conf
    echo -e "\033[1;32m/etc/resolv.conf 配置已恢复！\033[0m"
  else
    echo -e "\033[31m备份文件 /etc/resolv.conf.bak 不存在，无法恢复！\033[0m"
  fi
  ;;
7)
  echo -e "\033[1;34m检测流媒体解锁支持情况 (功能待实现)...\033[0m"
  ;;

8)
  # 检查端口 53 占用情况
  check_and_release_port 53
  ;;

9)
  # 删除本脚本
  echo "执行删除本脚本文件的操作..."
  rm -- "$0"
  echo -e "\033[1;32m脚本已成功删除！\033[0m"
  ;;

10)
  # 更换 resolv.conf 中的 nameserver
  echo -e "\033[1;33m请选择要更换的 nameserver：\033[0m"
  echo -e "\033[1;36m1.\033[0m \033[1;32m更换为香港 HK nameserver: 154.12.177.22\033[0m"
  echo -e "\033[1;36m2.\033[0m \033[1;32m更换为新加坡 SG nameserver: 157.20.104.47\033[0m"
  echo -e "\033[1;33m请输入数字 (1-2):\033[0m"
  read ns_choice

  case $ns_choice in
  1)
    set_and_lock_resolv_conf "154.12.177.22"
    ;;

  2)
    set_and_lock_resolv_conf "157.20.104.47"
    ;;

  *)
    echo -e "\033[31m无效选择，请输入 1 或 2！\033[0m"
    ;;
  esac
  ;;

*)
  # 处理无效输入
  echo -e "\033[31m无效选择，请输入 1-10 之间的数字！\033[0m"
  ;;
esac
