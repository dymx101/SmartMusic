import Foundation
import SwiftData

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchFavorites()
    }
    
    func fetchFavorites() {
        logger.info("Fetching favorites")
        let descriptor = FetchDescriptor<Favorite>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        favorites = (try? modelContext.fetch(descriptor)) ?? []
        logger.info("Fetched \(favorites.count) favorites")
    }
    
    func addFavorite(_ song: Song) {
        logger.info("Adding song to favorites: \(song.title)")
        let favorite = Favorite(song: song)
        modelContext.insert(favorite)
        
        do {
            try modelContext.save()
            logger.info("Successfully added to favorites")
        } catch {
            logger.error("Failed to add favorite: \(error.localizedDescription)")
        }
        
        fetchFavorites()
    }
    
    func removeFavorite(_ favorite: Favorite) {
        logger.info("Removing song from favorites: \(favorite.song.title)")
        modelContext.delete(favorite)
        
        do {
            try modelContext.save()
            logger.info("Successfully removed from favorites")
        } catch {
            logger.error("Failed to remove favorite: \(error.localizedDescription)")
        }
        
        fetchFavorites()
    }
    
    func isFavorite(_ song: Song) -> Bool {
        logger.debug("Checking favorite status for song: \(song.title)")
        return favorites.contains { $0.song.id == song.id }
    }
}
