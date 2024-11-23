#!/bin/bash

# 一键管理和配置 dnsmasq 脚本
# 请确保使用 sudo 或 root 权限运行此脚本

# 脚本版本和更新时间
VERSION="V_0.4 test"
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
  # 卸载 dnsmasq 并恢复默认配置
  echo -e "\033[1;34m正在卸载 dnsmasq...\033[0m"
  apt remove -y dnsmasq
  if ! command -v dnsmasq &> /dev/null; then
    echo -e "\033[1;32mdnsmasq 已成功卸载！\033[0m"
  else
    echo -e "\033[31mdnsmasq 卸载失败，请手动检查！\033[0m"
    exit 1
  fi
  # 恢复原始 /etc/resolv.conf 配置
  echo -e "\033[1;34m恢复原始 /etc/resolv.conf 配置...\033[0m"
  if [ -f /etc/resolv.conf.bak ]; then
    mv /etc/resolv.conf.bak /etc/resolv.conf
    echo -e "\033[1;32m/etc/resolv.conf 配置已恢复！\033[0m"
  else
    echo -e "\033[31m备份文件 /etc/resolv.conf.bak 不存在，无法恢复！\033[0m"
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
  echo -e "\033[1;34m正在检测流媒体解锁支持情况...\033[0m"
  bash <(curl -sL IP.Check.Place)
  if [ $? -eq 0 ]; then
    echo -e "\033[1;32m检测完成，请查看具体解锁信息！\033[0m"
  else
    echo -e "\033[31m检测失败，请检查网络或 IP.Check.Place 可用性！\033[0m"
  fi
  ;;

8)
  # 检查端口 53 占用情况
  echo -e "\033[1;34m正在检测系统端口 53 占用情况...\033[0m"
  netstat -tuln | grep ':53' > /dev/null
  if [ $? -eq 0 ]; then
    echo -e "\033[1;32m端口 53 被占用！\033[0m"
  else
    echo -e "\033[31m端口 53 未被占用！\033[0m"
  fi
  ;;

9)
  # 删除本脚本
  echo -e "\033[1;34m正在删除脚本文件...\033[0m"
  rm -- "$0"
  echo -e "\033[1;32m脚本已删除！\033[0m"
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
    echo -e "\033[1;34m设置 nameserver 为 154.12.177.22...\033[0m"
    echo "nameserver 154.12.177.22" > /etc/resolv.conf
    echo -e "\033[1;34m锁定 /etc/resolv.conf 文件...\033[0m"
    chattr +i /etc/resolv.conf
    echo -e "\033[1;32m操作成功！当前 nameserver 已设置为 154.12.177.22 并锁定。\033[0m"
    ;;

  2)
    echo -e "\033[1;34m设置 nameserver 为 157.20.104.47...\033[0m"
    echo "nameserver 157.20.104.47" > /etc/resolv.conf
    echo -e "\033[1;34m锁定 /etc/resolv.conf 文件...\033[0m"
    chattr +i /etc/resolv.conf
    echo -e "\033[1;32m操作成功！当前 nameserver 已设置为 157.20.104.47 并锁定。\033[0m"
    ;;


*)
  # 处理无效输入
  echo -e "\033[31m无效选择，请输入 1-9 之间的数字！\033[0m"
  ;;
esac
