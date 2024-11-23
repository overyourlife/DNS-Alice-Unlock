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
  # 检测流媒体解锁支持情况
  echo "检测流媒体解锁支持情况..."
  bash <(curl -sL IP.Check.Place)
  if [ $? -eq 0 ]; then
    echo "流媒体解锁检测完成！"
  else
    echo "流媒体解锁检测失败，请检查网络连接或脚本 URL！"
  fi
  ;;

8)
  # 检查端口 53 是否被占用
  echo "检查端口 53 是否被占用..."
  PORT_IN_USE=$(sudo netstat -tuln | grep ':53')
  if [ -n "$PORT_IN_USE" ]; then
    echo "端口 53 已被占用，检查是否为 systemd-resolved..."

    # 检查 systemd-resolved 是否占用了 53 端口
    SYSTEMD_RESOLVED=$(ps aux | grep 'systemd-resolved' | grep -v 'grep')

    if [ -n "$SYSTEMD_RESOLVED" ]; then
      echo "发现 systemd-resolved 占用 53 端口，正在停止并禁用 systemd-resolved 服务..."

      # 停止并禁用 systemd-resolved 服务
      sudo systemctl stop systemd-resolved
      sudo systemctl disable systemd-resolved

      # 删除 systemd-resolved 创建的 /etc/resolv.conf 并重新配置
      sudo rm -f /etc/resolv.conf
      echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf > /dev/null
      echo "/etc/resolv.conf 文件已更新为指向本地 DNS 解析。"
    else
      echo "系统未检测到 systemd-resolved 占用 53 端口，可能由其他进程占用。"
    fi
  else
    echo "端口 53 未被占用，可以正常启动 dnsmasq。"
  fi
  ;;


9)
  # 卸载本脚本并删除本地文件
  echo "正在卸载本脚本并删除本地文件..."
  if [ -f "$SCRIPT_NAME" ]; then
    rm -f "$SCRIPT_NAME"
    echo "脚本文件已删除！"
  else
    echo "脚本文件不存在，无法删除！"
  fi
  ;;

10)
  # 更换 resolv.conf 中的 nameserver
  echo -e "\033[1;33m请选择要更换的 nameserver：\033[0m"
  echo -e "\033[1;36m1.\033[0m \033[1;32m更换为 Alice 香港 HK nameserver\033[0m"
  echo -e "\033[1;36m2.\033[0m \033[1;32m更换为 Alice 新加坡 SG nameserver\033[0m"
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
