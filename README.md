Alice 大善人 DNS 一键分流脚本
支持操作系统: Debian & Ubuntu

项目简介
该脚本旨在帮助用户通过 Alice DNS 实现快速的 DNS 分流与全局 DNS 替换。只需简单的几个步骤，即可轻松配置与解锁 Alice DNS。适用于 VSP 用户，支持一键配置，无需复杂设置。

使用指南
步骤 1: 注册 Alice 账号
访问 Alice DNS 官网 进行注册。
在注册后，将您的 VPS IP 地址添加至 Alice 白名单。
注意：此过程可能需要 3-5 分钟生效。

步骤 2: 运行一键分流脚本
下载并运行以下脚本：

bash
复制代码
wget https://raw.githubusercontent.com/Jimmyzxk/DNS-Alice-Unlock/refs/heads/main/dns-unlock.sh && bash dns-unlock.sh
按照提示选择解锁方式：

解锁方式 1: 选择 1 安装 dnsmasq 分流配置。
解锁方式 2: 选择 10 将系统 DNS 全局替换为 Alice DNS。
功能特性
高效分流: 通过 dnsmasq 进行 DNS 分流，提升网络访问速度。
全局 DNS 替换: 全面替换系统 DNS 为 Alice DNS，提供更加稳定和安全的网络体验。
简化配置: 一键脚本自动配置，无需复杂操作，适合各类用户。
系统兼容性
Debian 系统
Ubuntu 系统
贡献
如果您有任何改进建议或发现问题，请随时提交 Issues 或 Pull Requests。我们欢迎社区的贡献，共同推动项目的进步！
