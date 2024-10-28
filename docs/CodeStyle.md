# 代码风格指南

## Swift 代码规范

### 命名规范
1. 类名：使用大驼峰命名法（PascalCase）
   - 示例：`AudioPlayer`, `HomeViewModel`

2. 变量和函数：使用小驼峰命名法（camelCase）
   - 示例：`currentSong`, `togglePlayPause()`

3. 常量：使用小驼峰命名法
   - 示例：`baseURL`, `defaultTimeout`

### 代码组织
1. 文件结构
   ```swift
   // 1. 导入
   import SwiftUI
   
   // 2. 类型定义
   struct ContentView: View {
       // 3. 属性
       @State private var isPlaying = false
       
       // 4. 计算属性
       var buttonImage: String {
           isPlaying ? "pause" : "play"
       }
       
       // 5. 初始化器
       init() {
           // 初始化代码
       }
       
       // 6. 视图构建
       var body: some View {
           // 视图代码
       }
       
       // 7. 辅助方法
       private func setupView() {
           // 设置代码
       }
   }
   ```

### 注释规范
1. 文件头注释
   ```swift
   //
   //  FileName.swift
   //  SmartMusic
   //
   //  Created by [Author] on [Date].
   //
   ```

2. 方法注释
   ```swift
   /// 播放指定的歌曲
   /// - Parameter song: 要播放的歌曲
   /// - Throws: 如果URL无效或播放失败则抛出错误
   func play(_ song: Song) throws {
       // 实现代码
   }
   ```

### SwiftUI 最佳实践
1. 视图拆分：保持每个视图简单且职责单一
2. 状态管理：适当使用 @State, @Binding, @ObservedObject
3. 性能优化：避免不必要的视图重建
