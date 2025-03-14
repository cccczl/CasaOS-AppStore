# CasaOS 应用商店贡献指南

本文档描述了如何向 CasaOS 应用商店贡献应用。

**重要提示**：您的 PR 必须首先在您自己的 CasaOS 上进行**充分测试**。这是您提交的强制性第一步。

**注意**：自 CasaOS v0.4.4 起，不再支持旧的 `appfile.json`。您的 PR 无需包含此文件。

**注意**：`image` 不要使用 `latest` 标签。 [Docker `:latest` 标签有什么问题？](https://github.com/cccczl/CasaOS-AppStore/issues/167)

## 提交流程

应用提交应通过 Pull Request 完成。Fork 此仓库并按照以下指南准备应用。

PR 准备就绪后，创建 PR 并将其分配给 CasaOS 团队的任何人或您信任的其他贡献者。

## 指南

### 项目结构

```shell
CasaOS-AppStore
├─ category-list.json   # 类别列表配置文件
├─ recommend-list.json  # 推荐应用列表配置文件
├─ featured-apps.json   # 待定
├─ help                 # 旧版本应用商店的帮助脚本
├─ Apps                 # 应用商店文件
├─ build                # 应用商店安装脚本
└─ psd-source           # 图标、缩略图、屏幕截图 PSD 模板
```

### 一个 CasaOS 应用通常包含以下文件

```shell
App-Name
├─ docker-compose.yml   # (必需) 有效的 Docker Compose 文件
├─ icon.png             # (必需) 应用图标
├─ screenshot-1.png     # (必需) 至少需要一张屏幕截图，以证明该应用在 CasaOS 上成功运行。
├─ screenshot-2.png     # (可选) 强烈建议提供更多屏幕截图以展示不同的功能。
├─ screenshot-3.png     # (可选) ...
└─ thumbnail.png        # (可选) 仅当您希望在应用商店首页推荐该应用时才需要缩略图文件。（请参阅底部的规范）
```

#### CasaOS 应用是一个 Docker Compose 应用，或 *compose 应用*

[Apps](Apps) 下的每个目录都对应一个 CasaOS 应用。该目录应至少包含一个 `docker-compose.yml` 文件：

- 它应该是一个有效的 [Docker Compose 文件](https://docs.docker.com/compose/compose-file/)。以下是一些要求（但不限于）：

  - `name` 只能包含小写字母、数字、下划线 "`_`" 和连字符 "`-`"（换句话说，必须匹配 `^[a-z0-9][a-z0-9_-]*$`）

- 镜像标签应该是特定的，例如 `:0.1.2`，而不是 `:latest`。

  > [Docker `:latest` 标签有什么问题？](https://github.com/cccczl/CasaOS-AppStore/issues/167)

- `name` 属性用作 *商店应用 ID*，在所有应用中应该是唯一的。

  例如，在 [Syncthing 的 `docker-compose.yml`](Apps/Syncthing/docker-compose.yml#L1) 中，其商店应用 ID 为 `syncthing`：

  ```yaml
  name: syncthing
  services:
      syncthing:
          image: linuxserver/syncthing:<specific version>
  ...
  ```

- 语言代码区分大小写，应全部为小写，例如 `en_us`、`zh_cn`。

- 在 `environment` 和 `volumes` 中可以使用一些系统级变量：

  ```yaml
  environment:
    PGID: $PGID                           # 预设组 ID
    PUID: $PUID                           # 预设用户 ID
    TZ: $TZ                               # 当前系统时区
  ...
  volumes:
    - type: bind
      source: /DATA/AppData/$AppID/config # $AppID = 应用名称，例如 syncthing
  ```

- CasaOS 特定的元数据，也称为 *商店信息*，存储在 [extension](https://docs.docker.com/compose/compose-file/#extension) 属性 `x-casaos` 下的两个位置。

  1. 服务级别

      一个 `docker-compose.yml` 文件可以包含一个或多个 `services`。[service](https://docs.docker.com/compose/compose-file/#services-top-level-element) 可以有自己的商店信息。

      对于相同的示例，在 [Syncthing 的 `docker-compose.yml`](Apps/Syncthing/docker-compose.yml) 中 `syncthing` 服务的底部

      ```yaml
      x-casaos:
          envs:                           # 每个环境变量的描述
              ...
            - container: PUID
              description:
                  en_us: 以指定 uid 运行 Syncthing。
          ports:                          # 每个端口的描述
            - container: "8384"
              description:
                  en_us: WebUI HTTP 端口
              ...
          volumes:                        # 每个卷的描述
              - container: /config
                description:
                    en_us: Syncthing 配置文件目录。
              - container: /DATA
                description:
                  en_us: Syncthing 可访问目录。
      ```

  2. Compose 应用级别

      对于相同的示例，在 [Syncthing 的 `docker-compose.yml`](Apps/Syncthing/docker-compose.yml) 的底部

      ```yaml
      x-casaos:
          architectures:                  # 应用支持的架构列表
              - amd64
              - arm
              - arm64
          main: syncthing                 # `services` 下主服务的名称
          author: CasaOS Team
          category: Backup
          description:                    # 支持多种语言环境
              en_us: Syncthing 是一个连续文件同步程序。它在两个或多个计算机之间实时同步文件，安全地保护数据免受窥探。您的数据是您自己的数据，您有权选择数据的存储位置、是否与第三方共享以及如何在互联网上传输。
          developer: Syncthing
          icon: https://cdn.jsdelivr.net/gh/cccczl/CasaOS-AppStore@main/Apps/Syncthing/icon.png
          tagline:                        # 支持多种语言环境
              en_us: 免费、安全和分布式的的文件同步工具。
          thumbnail: https://cdn.jsdelivr.net/gh/cccczl/CasaOS-AppStore@main/Apps/Jellyfin/thumbnail.jpg
          title:                          # 支持多种语言环境
              en_us: Syncthing
          tips:
              before_install:
                  en_us: |
                      （安装前供用户阅读的一些注意事项，例如预设的 `username` 和 `password` - 支持 markdown！）
          index: /                        # Web UI 的索引页，例如 index.html
          port_map: "8384"                # Web UI 的端口
      ```

  3. 魔法值

      **注意**：此功能仅在 casaos 0.4.4 及更高版本中有效。

      为了解决某些情况，CasaOS 提供了一些魔法值来增强您的应用程序：

      - 环境变量

          您的应用程序可以读取用户设置的环境变量，例如来自环境变量的 `OPENAI_API_KEY`。它存储在 `/etc/casaos/env` 中。用户只需设置一次，即可在任何地方使用。它可以通过 API 更改，更改后，所有应用程序将重新启动以注入新的环境变量。

          **注意**：更改配置不会更改当前容器的环境变量。要设置环境变量，您应该使用 CLI 进行设置。

      - `WEBUI_PORT`

          您的 `docker-compose.yml` 可以使用 `WEBUI_PORT` 来设置 WebUI 端口。CasaOS 将为您的应用程序分配一个可用端口。您可以像这样使用它：

          ```yaml
          ...
          ports:
              - target: 5230
                published: ${WEBUI_PORT}
                protocol: tcp
          ...
          x-casaos:
              architectures:
                  - amd64
                  - arm64
                  - arm
          ...
              port_map: ${WEBUI_PORT}
          ```

          或者

          ```yaml
          ...
          ports:
              - target: 5230
                published: ${WEBUI_PORT:-5230}
                protocol: tcp
          ...
          x-casaos:
              architectures:
                  - amd64
                  - arm64
                  - arm
          ...
              port_map: ${WEBUI_PORT:-5230}
          ```

          **注意**：`WEBUI_PORT` 只分配一次。它保证分配时端口是可用的。如果端口被其他应用程序使用，则不会重新分配新端口。

## 推荐应用的要求

我们偶尔会挑选一些应用作为推荐应用，并在应用商店首页展示。推荐应用的标准比其他应用略高：

- 图标图像应为透明背景的 PNG 图像，尺寸为 192x192 像素。
- 缩略图图像应为 784x442 像素，带有圆角蒙版。建议保存为透明背景的 PNG 图像。
- 屏幕截图图像应为 1280x720 像素，可以保存为 PNG 或 JPG 格式。请尽量保持文件大小尽可能小。

如果您需要，可以在 [PSD 模板文件](psd-source) 中找到准备好的模板，以快速创建上述图像。

如果您对此贡献过程有任何反馈和建议，请立即通过 Discord 或 Issues 告知我们。谢谢！