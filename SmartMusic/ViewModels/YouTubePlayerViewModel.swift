import Foundation

@MainActor
class YouTubePlayerViewModel: ObservableObject {
    @Published var videoTitle = ""
    @Published var channelTitle = ""
    @Published var videoDescription = ""
    
    private let youtubeService = YouTubeService.shared
    private let logger = LogService.shared
    
    func loadVideo(videoId: String) {
        Task {
            do {
                let videoDetails = try await youtubeService.getVideoDetails(videoId: videoId)
                videoTitle = videoDetails.title
                channelTitle = videoDetails.channelTitle
                videoDescription = videoDetails.description
                logger.info("Successfully loaded video details")
            } catch {
                logger.error("Failed to load video: \(error)")
            }
        }
    }
} 