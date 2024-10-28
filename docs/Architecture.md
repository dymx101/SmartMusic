# SmartMusic 应用架构文档

## 整体架构

SmartMusic 采用 MVVM (Model-View-ViewModel) 架构模式，并结合 SwiftUI 和 SwiftData 框架进行开发。

### 核心架构组件

1. **Models（数据模型）**
   - 使用 SwiftData 的 `@Model` 宏定义数据模型
   - 包括：Song、Playlist、User、Favorite、PlayHistory 等模型

2. **Views（视图层）**
   - 使用 SwiftUI 构建用户界面
   - 按功能模块组织：Home、Search、Player、Playlist、Profile 等

3. **ViewModels（视图模型）**
   - 处理业务逻辑
   - 管理数据状态
   - 提供视图所需的数据和操作方法

4. **Services（服务层）**
   - NetworkService：处理网络请求
   - AudioPlayer：管理音频播放
   - 提供全局共享的功能

### 数据流

1. **单向数据流**
   - ViewModel 从 Model 获取数据
   - View 通过 ViewModel 展示数据
   - 用户操作触发 ViewModel 的方法
   - ViewModel 更新 Model 和状态

2. **状态管理**
   - 使用 SwiftUI 的 `@State` 和 `@Published` 管理视图状态
   - 使用 Combine 框架处理异步操作和数据绑定

### 持久化存储

- 使用 SwiftData 管理本地数据
- 包括：播放列表、收藏、历史记录等

### 模块划分

1. **首页模块**
   - 推荐歌曲展示
   - 轮播图
   - 分类入口

2. **搜索模块**
   - 搜索功能
   - 搜索结果展示
   - 搜索历史

3. **播放器模块**
   - 音乐播放控制
   - 迷你播放器
   - 全屏播放界面

4. **播放列表模块**
   - 播放列表管理
   - 歌曲管理

5. **个人中心模块**
   - 用户信息
   - 收藏管理
   - 播放历史
   - 设置
