import Foundation

enum PlayMode {
    case sequence   // 顺序播放
    case random     // 随机播放
    case single     // 单曲循环
}

class PlaybackQueue: ObservableObject {
    static let shared = PlaybackQueue()
    private let logger = LogService.shared
    
    // 当前播放模式
    @Published var playMode: PlayMode = .sequence
    
    // 当前播放列表
    @Published private(set) var currentQueue: [Song] = []
    
    // 当前播放索引
    @Published private(set) var currentIndex: Int = 0
    
    // 当前播放歌曲
    @Published private(set) var currentSong: Song?
    
    private init() {}
    
    // 设置新的播放队列
    func setQueue(songs: [Song], startIndex: Int = 0) {
        logger.info("Setting new queue with \(songs.count) songs, starting at index \(startIndex)")
        currentQueue = songs
        currentIndex = startIndex
        currentSong = songs[safe: startIndex]
    }
    
    // 获取下一首歌
    func getNextSong() -> Song? {
        switch playMode {
        case .sequence:
            return getNextSequentialSong()
        case .random:
            return getRandomSong()
        case .single:
            return currentSong
        }
    }
    
    // 获取上一首歌
    func getPreviousSong() -> Song? {
        switch playMode {
        case .sequence:
            return getPreviousSequentialSong()
        case .random:
            return getRandomSong()
        case .single:
            return currentSong
        }
    }
    
    // 切换播放模式
    func togglePlayMode() {
        switch playMode {
        case .sequence:
            playMode = .random
            logger.info("Switched to random play mode")
        case .random:
            playMode = .single
            logger.info("Switched to single play mode")
        case .single:
            playMode = .sequence
            logger.info("Switched to sequence play mode")
        }
    }
    
    // 私有方法: 获取顺序播放的下一首歌
    private func getNextSequentialSong() -> Song? {
        guard !currentQueue.isEmpty else {
            logger.warning("Queue is empty")
            return nil
        }
        
        let nextIndex = (currentIndex + 1) % currentQueue.count
        currentIndex = nextIndex
        currentSong = currentQueue[nextIndex]
        logger.info("Getting next sequential song: \(currentSong?.title ?? "nil")")
        return currentSong
    }
    
    // 私有方法: 获取顺序播放的上一首歌
    private func getPreviousSequentialSong() -> Song? {
        guard !currentQueue.isEmpty else {
            logger.warning("Queue is empty")
            return nil
        }
        
        let previousIndex = (currentIndex - 1 + currentQueue.count) % currentQueue.count
        currentIndex = previousIndex
        currentSong = currentQueue[previousIndex]
        logger.info("Getting previous sequential song: \(currentSong?.title ?? "nil")")
        return currentSong
    }
    
    // 私有方法: 获取随机歌曲
    private func getRandomSong() -> Song? {
        guard !currentQueue.isEmpty else {
            logger.warning("Queue is empty")
            return nil
        }
        
        let randomIndex = Int.random(in: 0..<currentQueue.count)
        currentIndex = randomIndex
        currentSong = currentQueue[randomIndex]
        logger.info("Getting random song: \(currentSong?.title ?? "nil")")
        return currentSong
    }
}

// 安全数组访问扩展
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 