# 部署指南

## 开发环境配置

### 1. Xcode 配置
- Xcode 14.0+
- iOS SDK 15.0+
- Swift 5.5+

### 2. 证书配置
1. 开发证书
   - 在 Apple Developer 账号中创建开发证书
   - 在 Xcode 中配置开发团队
   - 配置 Bundle Identifier

2. 推送证书（如需要）
   - 创建 APNs 证书
   - 配置推送功能

### 3. 依赖管理
- 使用系统原生框架，无需第三方依赖

## 构建配置

### 1. 编译配置
```xcconfig
SWIFT_VERSION = 5.0
IPHONEOS_DEPLOYMENT_TARGET = 15.0
TARGETED_DEVICE_FAMILY = 1,2
ENABLE_BITCODE = NO
```

### 2. 环境配置
1. 开发环境
   ```swift
   let baseURL = "http://35.188.0.156:8000/api"
   ```

2. 生产环境
   ```swift
   let baseURL = "https://api.smartmusic.com"
   ```

## 发布流程

### 1. 版本管理
- 使用语义化版本号（Semantic Versioning）
- 更新 Info.plist 中的版本号
- 创建发布标签

### 2. App Store 发布
1. 准备材料
   - App 图标
   - 截图
   - 描述文案
   - 关键词

2. 提交审核
   - 构建生产版本
   - 上传到 App Store Connect
   - 填写审核信息
   - 提交审核

### 3. 发布后监控
- 崩溃监控
- 性能监控
- 用户反馈
