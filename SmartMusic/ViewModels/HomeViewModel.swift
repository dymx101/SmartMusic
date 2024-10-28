import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recommendedSongs: [Song] = []
    @Published var featuredSongs: [Song] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let logger = LogService.shared

    func fetchRecommendedSongs() async {
        logger.info("Fetching recommended songs")
        isLoading = true
        
        do {
            recommendedSongs = try await NetworkService.shared.fetch("/recommended-songs")
            logger.info("Successfully fetched \(recommendedSongs.count) recommended songs")
        } catch {
            logger.error("Failed to fetch recommended songs: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchFeaturedSongs() async {
        do {
            featuredSongs = try await NetworkService.shared.fetch("/featured-songs")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
