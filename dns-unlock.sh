#!/bin/bash

# 一键管理和配置 dnsmasq 脚本
# 请确保使用 sudo 或 root 权限运行此脚本

# 指定配置文件的下载地址
CONFIG_URL="https://raw.githubusercontent.com/Jimmyzxk/DNS-Alice-Unlock/refs/heads/main/dnsmasq.conf"
CONFIG_FILE="/etc/dnsmasq.conf"

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本！"
  exit 1
fi

# 检查系统是否为 Debian/Ubuntu
if ! grep -Ei 'debian|ubuntu' /etc/os-release > /dev/null; then
  echo "此脚本仅适用于 Debian 和 Ubuntu 系统！"
  exit 1
fi

# 显示菜单
echo "请选择要执行的操作："
echo "1. 安装 dnsmasq"
echo "2. 卸载 dnsmasq"
echo "3. 一键更新 dnsmasq 配置文件"
echo "4. 解锁 /etc/resolv.conf 文件"
echo "5. 锁定 /etc/resolv.conf 文件"
echo "6. 恢复原始 /etc/resolv.conf.bak 文件"
echo "7. 检测流媒体解锁支持情况"
echo "8. 检查端口 53 是否被占用"
read -p "请输入数字 (1-8): " choice

case $choice in
1)
  # 安装 dnsmasq
  echo "正在安装 dnsmasq..."
  apt update -y && apt install -y dnsmasq curl
  if command -v dnsmasq &> /dev/null; then
    echo "dnsmasq 安装成功！"
  else
    echo "dnsmasq 安装失败，请检查网络或软件源设置！"
    exit 1
  fi

  # 下载 dnsmasq 配置文件
  echo "下载并应用 dnsmasq 配置文件..."
  if curl -o "$CONFIG_FILE" "$CONFIG_URL"; then
    echo "配置文件下载成功！"
  else
    echo "配置文件下载失败，请检查网络连接或 URL 是否正确！"
    exit 1
  fi

  # 备份并配置 /etc/resolv.conf
  echo "备份并配置 /etc/resolv.conf 文件..."
  if [ -f /etc/resolv.conf ]; then
    mv /etc/resolv.conf /etc/resolv.conf.bak
    rm -f /etc/resolv.conf
  fi

  echo "创建新的 /etc/resolv.conf 文件，并设置 nameserver 为 127.0.0.1..."
  echo "nameserver 127.0.0.1" > /etc/resolv.conf

  echo "锁定 /etc/resolv.conf 文件，防止被修改..."
  chattr +i /etc/resolv.conf
  echo "/etc/resolv.conf 文件已成功更新并锁定！"

  # 重启 dnsmasq 服务
  echo "重启 dnsmasq 服务..."
  systemctl restart dnsmasq

  # 检查服务状态
  if systemctl is-active --quiet dnsmasq; then
    echo "dnsmasq 服务已成功重新启动！"
  else
    echo "dnsmasq 服务启动失败，请检查配置文件是否正确！"
    exit 1
  fi
  ;;

2)
  # 卸载 dnsmasq
  echo "正在卸载 dnsmasq..."
  apt remove -y dnsmasq
  if ! command -v dnsmasq &> /dev/null; then
    echo "dnsmasq 已成功卸载！"
  else
    echo "dnsmasq 卸载失败，请手动检查！"
    exit 1
  fi
  ;;

3)
  # 更新 dnsmasq 配置文件
  echo "备份原有的 dnsmasq 配置文件..."
  if [ -f "$CONFIG_FILE" ]; then
    mv "$CONFIG_FILE" "${CONFIG_FILE}.bak"
  fi

  echo "从远程下载新的配置文件..."
  if curl -o "$CONFIG_FILE" "$CONFIG_URL"; then
    echo "配置文件更新成功！"
  else
    echo "配置文件下载失败，请检查网络连接或 URL 是否正确！"
    exit 1
  fi

  # 重启 dnsmasq 服务
  echo "重启 dnsmasq 服务..."
  systemctl restart dnsmasq

  # 检查服务状态
  if systemctl is-active --quiet dnsmasq; then
    echo "dnsmasq 服务已成功重新启动！"
  else
    echo "dnsmasq 服务启动失败，请检查配置文件是否正确！"
    exit 1
  fi
  ;;

4)
  # 解锁 /etc/resolv.conf
  echo "解锁 /etc/resolv.conf 文件..."
  chattr -i /etc/resolv.conf
  echo "/etc/resolv.conf 文件已解锁！"
  ;;

5)
  # 锁定 /etc/resolv.conf
  echo "锁定 /etc/resolv.conf 文件..."
  chattr +i /etc/resolv.conf
  echo "/etc/resolv.conf 文件已锁定！"
  ;;

6)
  # 恢复 /etc/resolv.conf.bak
  echo "恢复 /etc/resolv.conf 文件..."
  if [ -f /etc/resolv.conf.bak ]; then
    chattr -i /etc/resolv.conf 2>/dev/null
    mv /etc/resolv.conf.bak /etc/resolv.conf
    chattr +i /etc/resolv.conf
    echo "/etc/resolv.conf 文件已从备份恢复并锁定！"
  else
    echo "备份文件 /etc/resolv.conf.bak 不存在，无法恢复！"
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

*)
  echo "无效选项，请重新运行脚本并选择 1-8。"
  exit 1
  ;;
esac

echo "操作完成！"
