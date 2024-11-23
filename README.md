# Alice 大善人 DNS 一键分流脚本

**支持操作系统**: Debian & Ubuntu

## 项目简介

该脚本通过 **Alice DNS** 提供简便、快速且高效的 DNS 分流与全局 DNS 替换功能。适用于 VPS 用户，在无须复杂配置的情况下，便能轻松实现 DNS 流量优化，提升网络性能与安全性。项目旨在帮助用户突破 DNS 限制，实现更快的网络访问体验。

通过此脚本，用户可以根据需要选择不同的解锁方式，快速部署 Alice DNS 或配置 DNS 分流。该脚本特别适合需要快速实现 DNS 优化和流量分流的用户。

## 功能特性

- **高效 DNS 分流**：通过 `dnsmasq` 配置分流策略，实现高速稳定的 DNS 查询。
- **全局 DNS 替换**：无缝替换系统 DNS 为 Alice DNS，提供更快的响应速度和更高的安全性。
- **一键自动化配置**：提供简单的命令行操作，自动完成 DNS 配置，降低配置门槛。
- **兼容 Debian 和 Ubuntu 系统**：该脚本经过优化，确保在 Debian 和 Ubuntu 系统上运行无缝。

## 使用指南

### 步骤 1: 注册 Alice 账号
1. 访问 [Alice DNS 官网](https://app.alice.ws) 进行注册。
2. 在 Alice 后台将您的 VPS IP 地址添加至白名单。  
   > **注意**：此过程可能需要 3-5 分钟才能生效，请耐心等待。

### 步骤 2: 运行一键分流脚本
1. 下载并执行以下命令：
   ```bash
   wget https://raw.githubusercontent.com/Jimmyzxk/DNS-Alice-Unlock/refs/heads/main/dns-unlock.sh && bash dns-unlock.sh

