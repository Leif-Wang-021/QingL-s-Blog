---
title: "wild 鸿蒙版：轻小说阅读与离线体验优化"
published: 2026-10-07
description: "介绍 wild 非官方鸿蒙分支的阅读功能、本地缓存、离线目录与下载恢复，并提供源码和 HAP 下载入口。"
tags: ["wild", "轻小说", "Flutter", "HarmonyOS"]
category: 软件项目
draft: false
lang: zh_CN
updated: 2026-10-07
series: "wild 鸿蒙版"
seriesOrder: 1
---

**wild 鸿蒙版**是我基于 [niuhuan/wild](https://github.com/niuhuan/wild) 维护的非官方 HarmonyOS / OpenHarmony 移植分支。上游是用 Flutter 开发的轻小说文库（文库 8）第三方客户端，这个分支保留原有阅读体验，并补充鸿蒙真机运行所需的平台适配。

鸿蒙适配代码由 AI 辅助编写，再由人进行调试和修复。项目与轻小说文库及其运营方无关。

**项目入口：**[源码仓库](https://github.com/Leif-Wang-021/wild-ohos) · [下载与更新日志](https://github.com/Leif-Wang-021/wild-ohos/releases) · [问题反馈](https://github.com/Leif-Wang-021/wild-ohos/issues)

## 阅读、书架与找书

这个分支保留了上游的主要功能，日常使用可以围绕“找书—加入书架—阅读—继续阅读”展开。

| 功能 | 支持内容 |
| :--- | :--- |
| 阅读器 | 章节跳转、正文插图、阅读进度保存与继续阅读 |
| 阅读设置 | 浅色、深色或跟随系统主题，字体大小、行高和段落间距调整，竖屏自动滚动 |
| 书架 | 分类管理、多选操作、网页书架同步 |
| 搜索 | 按书名或作者搜索、搜索历史、作者作品检索 |
| 分类与排行 | 分类标签，更新、热门、完结、动画化筛选，以及多种排行排序方式 |
| 使用记录 | 阅读历史与分类、排行浏览历史 |

## 界面展示

下面四张截图来自[本分支的截图目录](https://github.com/Leif-Wang-021/wild-ohos/tree/main/docs/screenshots)，分别展示首页、阅读历史、正文阅读和插图显示。

| 首页 | 阅读历史 |
| :---: | :---: |
| ![wild 鸿蒙版首页](./01-home.jpg) | ![wild 鸿蒙版阅读历史](./02-history.jpg) |

| 正文阅读 | 插图显示 |
| :---: | :---: |
| ![wild 鸿蒙版正文阅读界面](./03-reader.jpg) | ![wild 鸿蒙版插图显示界面](./04-illustration.jpg) |

## 离线体验的调整

截至本文发布，最新公开版本为 **v0.0.15-ohos.1**。这一版的重点是本地数据和下载恢复，具体变更记录在[版本发布页](https://github.com/Leif-Wang-021/wild-ohos/releases/tag/v0.0.15-ohos.1)。

### 本地有数据时优先读取

书架、阅读历史和小说详情会优先使用已有的本地数据，没有本地数据时再联网获取。联网加载书架后，后台还会逐本预取小说详情与目录，并保存缓存。

这样在网络不稳定时，已经缓存的书架和详情仍有可用数据，不必每次进入页面都完全依赖网络请求。

### 下载正文，也保存完整目录

离线阅读需要正文文件，也需要目录来定位章节。这个版本在下载小说时持久化完整目录 manifest，让已下载内容在断网后仍能进入阅读。

封面也按归一化后的 URL 生成哈希并保存到本地，使已经缓存的封面在离线时仍可显示。**离线能力以已完成下载和缓存的内容为前提**，新内容仍需要联网获取。

### 限流与断点续传

下载加入了 HTTP 429 全局冷却、自适应请求间隔和断点续传机制，减少请求被限流后反复失败的情况。下载速度和完成情况仍取决于网络与源站状态。

## 鸿蒙版本与下载

当前公开发布面向 **HarmonyOS NEXT 及以上版本的 arm64 真机**。仓库补充了图标、启动、WebView、URL 跳转和屏幕常亮等平台兼容处理；关于页也提供源码、反馈和 GitHub Release 更新检查入口。

- [下载 v0.0.15-ohos.1 HAP](https://github.com/Leif-Wang-021/wild-ohos/releases/download/v0.0.15-ohos.1/wild-v0.0.15-ohos.1-arm64-signed.hap)
- [查看该版本的完整发布说明](https://github.com/Leif-Wang-021/wild-ohos/releases/tag/v0.0.15-ohos.1)
- [查看后续最新版本](https://github.com/Leif-Wang-021/wild-ohos/releases/latest)

当前仓库按 arm64 真机包整理，默认不包含 x86_64 模拟器所需的原生库。下载的是 HAP 包，实际安装还需要匹配设备与签名条件；遇到安装问题时，请在反馈中附上系统版本和具体错误提示。

## 项目来源与反馈

本项目的上游为 [niuhuan/wild](https://github.com/niuhuan/wild)，鸿蒙分支为 [Leif-Wang-021/wild-ohos](https://github.com/Leif-Wang-021/wild-ohos)，沿用 **GPLv3** 协议，详见[仓库 LICENSE](https://github.com/Leif-Wang-021/wild-ohos/blob/main/LICENSE)。

功能与平台适配说明可查看[仓库 README](https://github.com/Leif-Wang-021/wild-ohos/blob/main/README.md)。如果遇到阅读、离线缓存或下载问题，欢迎提交 [Issue](https://github.com/Leif-Wang-021/wild-ohos/issues)，注明应用版本、设备型号、系统版本和复现步骤。

本文记录的是截至 **2026 年 10 月 7 日** 的公开版本状态，更新信息以 GitHub Releases 为准。
