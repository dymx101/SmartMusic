import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recommendedSongs: [Song] = []
    @Published var featuredSongs: [Song] = []
    @Published var genres: [Genre] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMorePages = true
    
    private let pageSize = 20
    private let logger = LogService.shared
    
    init() {
        fetchGenres()
    }
    
    func fetchRecommendedSongs(forceRefresh: Bool = false) async {
        // 如果不是强制刷新且已有数据，则直接返回
        if !forceRefresh && !recommendedSongs.isEmpty {
            return
        }
        
        isLoading = true
        currentPage = 1 // 重置页码
        
        do {
            let songs = try await NetworkService.shared.fetchRecommendedSongs(
                page: currentPage,
                pageSize: pageSize,
                query: "playback_count"
            )
            
            recommendedSongs = songs
            hasMorePages = songs.count == pageSize
            logger.info("Successfully fetched \(songs.count) recommended songs")
        } catch {
            logger.error("Failed to fetch recommended songs: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            hasMorePages = false
        }
        
        isLoading = false
    }
    
    func fetchGenres() {
        Task {
            do {
                genres = try await NetworkService.shared.fetchGenres()
                logger.info("Fetched \(genres.count) genres")
            } catch {
                logger.error("Failed to fetch genres: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
