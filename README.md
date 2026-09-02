# 解压 RAR - Mac 版

一个简单的 macOS `.rar` 解压小工具。

它适合不想记命令行的用户：把 `.rar` 文件拖到 App 上即可解压；设置为默认打开方式后，也可以双击 `.rar` 文件解压。

## 功能

- 支持 macOS
- 支持拖拽 `.rar` 文件到 App 上解压
- 支持设置为 `.rar` 文件的默认打开方式，实现双击解压
- 解压到压缩包所在目录的同名文件夹
- 如果同名文件夹已存在，会自动生成 `文件名 2`、`文件名 3` 这样的新目录
- 使用 macOS 系统自带的 `/usr/bin/bsdtar`

## 下载 Mac 版

推荐从 GitHub Release 下载：

[下载 RAR-macOS.zip](https://github.com/Gooooood-cc/rar-extractor-mac/releases/download/v1.0-mac/RAR-macOS.zip)

下载后解压，会得到：

```text
解压 RAR.app
```

## 安装

把 `解压 RAR.app` 放到以下任意一个位置：

```text
/Applications
```

或：

```text
~/Applications
```

如果只是临时使用，也可以不安装，直接把 `.rar` 文件拖到 `解压 RAR.app` 上。

## 使用方法

### 方法一：拖拽解压

1. 找到一个 `.rar` 文件
2. 把它拖到 `解压 RAR.app` 上
3. App 会在 `.rar` 文件旁边创建同名文件夹
4. 解压完成后，Finder 会显示解压结果

### 方法二：双击 `.rar` 解压

第一次需要手动设置默认打开方式：

1. 在 Finder 里右键任意 `.rar` 文件
2. 点击“显示简介”
3. 找到“打开方式”
4. 选择 `解压 RAR.app`
5. 点击“全部更改...”

以后双击 `.rar` 文件时，就会用 `解压 RAR.app` 解压。

## 解压结果示例

假设压缩包在桌面：

```text
~/Desktop/example.rar
```

解压后会生成：

```text
~/Desktop/example/
```

如果 `example/` 已经存在，会生成：

```text
~/Desktop/example 2/
```

## 常见问题

### 双击 App 时只弹出提示

这是正常的。这个 App 需要接收 `.rar` 文件。

请把 `.rar` 文件拖到 App 上，或者把它设置为 `.rar` 文件的默认打开方式。

### macOS 提示 App 来自未知开发者

这个项目没有做 Apple 开发者证书签名和 notarization。

如果 macOS 阻止打开，可以在“系统设置”里允许打开，或者右键 App 后选择“打开”。

### 为什么不用 macOS 自带双击解压

macOS 自带的“归档实用工具”主要适合 `.zip`。它对 `.rar`，尤其是 RAR v5，支持不稳定。

这个工具通过 `/usr/bin/bsdtar` 解压，解决 Finder 双击 `.rar` 不好用的问题。

### 会读取或上传我的文件吗

不会。

工具只在本机调用 `/usr/bin/bsdtar` 解压文件，不上传内容，也不读取压缩包里文档的正文。

## 从源码构建

需要 macOS 和命令行开发工具。

```bash
./build.sh
```

构建完成后会生成：

```text
dist/解压 RAR.app
dist/解压 RAR-macOS.zip
```

## 项目结构

```text
.
├── README.md
├── build.sh
├── dist/
│   └── 解压 RAR-macOS.zip
└── src/
    ├── Info.plist
    └── RarExtractor.m
```

## 适用平台

这是 Mac 版，仅适用于 macOS。
