#!/bin/bash

# 一键管理和配置 dnsmasq 脚本
VERSION="V_0.6"
LAST_UPDATED=$(date +"%Y-%m-%d")
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

# 显示标题
echo -e "\033[1;34m======================================\033[0m"
echo -e "\033[1;32m       一键配置 dnsmasq 分流脚本       \033[0m"
echo -e "\033[1;36m       版本：  $VERSION       \033[0m"
echo -e "\033[1;36m       更新时间：$LAST_UPDATED       \033[0m"
echo -e "\033[1;36m       本脚本由 $AUTHOR 维护       \033[0m"
echo -e "\033[1;34m======================================\033[0m\n"

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
  echo "nameserver $nameserver" > /etc/resolv.conf
  chattr +i /etc/resolv.conf
  echo -e "\033[1;32m操作成功！当前 nameserver 已设置为 $nameserver 并已锁定。\033[0m"
}

# 主菜单显示
echo -e "\033[1;33m请选择要执行的操作：\033[0m"
cat <<MENU
1. 安装并配置 dnsmasq 分流
2. 卸载 dnsmasq 并恢复默认配置
3. 更新 dnsmasq 配置文件
4. 解锁 /etc/resolv.conf 文件
5. 锁定 /etc/resolv.conf 文件
6. 恢复原始 /etc/resolv.conf 配置
7. 检测流媒体解锁支持情况
8. 检查系统端口 53 占用情况
9. 删除本脚本文件
10. 一键更换 resolv.conf 中的 nameserver
MENU
echo -e "\n\033[1;33m请输入数字 (1-10):\033[0m"
read choice

case $choice in
1)
  echo -e "\033[1;34m安装并配置 dnsmasq...\033[0m"
  apt update && apt install -y dnsmasq
  curl -o $CONFIG_FILE $CONFIG_URL
  if [ $? -eq 0 ]; then
    echo -e "\033[1;32m配置文件下载成功！\033[0m"
  else
    echo -e "\033[31m配置文件下载失败，请检查网络！\033[0m"
    exit 1
  fi
  check_and_release_port 53
  systemctl restart dnsmasq && systemctl enable dnsmasq
  echo -e "\033[1;32mdnsmasq 安装与配置完成！\033[0m"
  ;;

2)
  echo -e "\033[1;34m卸载 dnsmasq...\033[0m"
  apt remove -y dnsmasq && rm -f $CONFIG_FILE
  echo -e "\033[1;32mdnsmasq 已卸载，默认配置恢复！\033[0m"
  ;;

3)
  echo -e "\033[1;34m更新 dnsmasq 配置文件...\033[0m"
  curl -o $CONFIG_FILE $CONFIG_URL
  echo -e "\033[1;32m配置文件已更新，重启 dnsmasq 服务中...\033[0m"
  systemctl restart dnsmasq
  ;;

4)
  echo -e "\033[1;34m解锁 /etc/resolv.conf 文件...\033[0m"
  chattr -i /etc/resolv.conf
  echo -e "\033[1;32m/etc/resolv.conf 已解锁！\033[0m"
  ;;

5)
  echo -e "\033[1;34m锁定 /etc/resolv.conf 文件...\033[0m"
  chattr +i /etc/resolv.conf
  echo -e "\033[1;32m/etc/resolv.conf 已锁定！\033[0m"
  ;;

6)
  echo -e "\033[1;34m恢复原始 /etc/resolv.conf 配置...\033[0m"
  if [ -f /etc/resolv.conf.bak ]; then
    mv /etc/resolv.conf.bak /etc/resolv.conf
    echo -e "\033[1;32m/etc/resolv.conf 已恢复！\033[0m"
  else
    echo -e "\033[31m找不到备份文件，无法恢复。\033[0m"
  fi
  ;;

7)
  echo -e "\033[1;34m检测流媒体解锁支持情况 (功能待实现)...\033[0m"
  ;;

8)
  check_and_release_port 53
  ;;

9)
  echo -e "\033[1;34m删除本脚本文件...\033[0m"
  rm -f "$0"
  echo -e "\033[1;32m脚本已删除！\033[0m"
  ;;

10)
  echo -e "\033[1;34m选择要设置的 nameserver：\033[0m"
  echo -e "1. 香港: 154.12.177.22\n2. 新加坡: 157.20.104.47"
  read ns_choice
  case $ns_choice in
    1) set_and_lock_resolv_conf 154.12.177.22 ;;
    2) set_and_lock_resolv_conf 157.20.104.47 ;;
    *) echo -e "\033[31m无效选择。\033[0m" ;;
  esac
  ;;

*)
  echo -e "\033[31m无效输入，请选择 1-10。\033[0m"
  ;;
esac
