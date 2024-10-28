# 数据模型说明

## Song
歌曲模型，包含歌曲的基本信息：
- id: 唯一标识符
- title: 歌曲名称
- artist: 艺术家
- albumCover: 专辑封面
- duration: 时长
- url: 音频文件地址

## Playlist
播放列表模型：
- id: 唯一标识符
- name: 播放列表名称
- songs: 包含的歌曲
- createdAt: 创建时间

## User
用户模型：
- id: 唯一标识符
- username: 用户名
- avatar: 头像
- favoriteCount: 收藏数
- playlistCount: 播放列表数
- historyCount: 历史记录数

## Favorite
收藏模型：
- id: 唯一标识符
- song: 收藏的歌曲
- createdAt: 收藏时间

## PlayHistory
播放历史模型：
- id: 唯一标识符
- song: 播放的歌曲
- playCount: 播放次数
- lastPlayedAt: 最后播放时间
