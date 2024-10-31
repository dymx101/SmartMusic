import Foundation

@MainActor
class YouTubeMusicViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var videos: [YouTubeVideo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let youtubeService = YouTubeService.shared
    private let logger = LogService.shared
    
    func fetchVideos() async {
        isLoading = true
        
        do {
            let songs = try await youtubeService.getTrendingMusic()
            videos = songs.map { song in
                YouTubeVideo(
                    id: song.permalink ?? "",
                    title: song.title,
                    description: song.songDescription ?? "No description",
                    thumbnailUrl: song.permalinkImage ?? "",
                    channelTitle: song.artist,
                    publishedAt: song.releaseDate ?? ""
                )
            }
            logger.info("Successfully fetched YouTube videos")
        } catch {
            logger.error("Failed to fetch YouTube videos: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchVideos() async {
        guard !searchQuery.isEmpty else { return }
        isLoading = true
        
        do {
            let songs = try await youtubeService.searchMusic(query: searchQuery)
            videos = songs.map { song in
                YouTubeVideo(
                    id: song.permalink ?? "",
                    title: song.title,
                    description: song.songDescription ?? "No description",
                    thumbnailUrl: song.permalinkImage ?? "",
                    channelTitle: song.artist,
                    publishedAt: song.releaseDate ?? ""
                )
            }
            logger.info("Successfully searched YouTube videos")
        } catch {
            logger.error("Failed to search YouTube videos: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 
