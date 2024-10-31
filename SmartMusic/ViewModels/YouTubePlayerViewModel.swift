import Foundation
import AVKit

@MainActor
class YouTubePlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var videoTitle = ""
    @Published var channelTitle = ""
    @Published var videoDescription = ""
    
    private let youtubeService = YouTubeService.shared
    private let logger = LogService.shared
    
    func loadVideo(videoId: String) {
        Task {
            do {
                // 获取视频详情
                let videoDetails = try await youtubeService.getVideoDetails(videoId: videoId)
                videoTitle = videoDetails.title
                channelTitle = videoDetails.channelTitle
                videoDescription = videoDetails.description
                
                // 创建播放器
                if let url = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
                    let playerItem = AVPlayerItem(url: url)
                    player = AVPlayer(playerItem: playerItem)
                    player?.play()
                    isPlaying = true
                }
            } catch {
                logger.error("Failed to load video: \(error)")
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    func replay10Seconds() {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeGetSeconds(currentTime) - 10.0
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    func forward10Seconds() {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeGetSeconds(currentTime) + 10.0
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        isPlaying = false
    }
} 