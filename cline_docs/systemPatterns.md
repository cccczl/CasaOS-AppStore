# System Patterns

## 系统架构模式

内容分发网络 (CDN) 模式。应用商店数据存储在 GitHub 仓库中，CasaOS 系统作为客户端从 GitHub 仓库拉取数据。

## 关键技术决策

*   使用 Docker Compose 作为应用部署标准，简化应用定义和部署流程。
*   使用 GitHub 存储和分发应用商店数据，利用 GitHub 的版本控制和协作功能。
*   采用 JSON 格式作为配置文件，易于解析和生成。

## 架构模式

客户端-内容分发网络 (Client-CDN) 模式。CasaOS 系统作为客户端，GitHub 仓库作为内容分发网络。