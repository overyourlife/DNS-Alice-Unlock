# Alice 大善人 DNS 多媒体一键分流脚本

**支持操作系统**: Debian & Ubuntu

## 项目简介

该脚本旨在帮助用户通过 **Alice DNS** 实现快速的 DNS 分流与全局 DNS 替换。只需简单的几个步骤，即可轻松配置与解锁 Alice DNS。适用于 VPS 用户，支持一键配置，无需复杂设置。

## 使用指南

### 步骤 1: 注册 Alice 账号
1. 访问 [Alice DNS 官网](https://app.alice.ws) 进行注册。
2. 在注册后，将您的 VPS IP 地址添加至 Alice 白名单。
   > **注意**：此过程可能需要 3-5 分钟生效。

### 步骤 2: 运行一键分流脚本
1. 下载并运行以下脚本：
   ```bash
   wget https://raw.githubusercontent.com/Jimmyzxk/DNS-Alice-Unlock/refs/heads/main/dns-unlock.sh && bash dns-unlock.sh
