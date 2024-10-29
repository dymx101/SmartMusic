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
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesChanged),
            name: Self.favoritesChangedNotification,
            object: nil
        )
    }
    
    @objc private func favoritesChanged() {
        Task { @MainActor in
            fetchFavorites()
        }
    }
    
    func fetchFavorites() {
        logger.info("Fetching favorites")
        let descriptor = FetchDescriptor<Favorite>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        favorites = (try? modelContext.fetch(descriptor)) ?? []
        logger.info("Fetched \(favorites.count) favorites")
    }
    
    func addFavorite(_ song: Song) {
        Task { @MainActor in
            logger.info("Adding song to favorites: \(song.title)")
            
            // 检查是否已经存在
            let descriptor = FetchDescriptor<Favorite>()
            let existingFavorites = (try? modelContext.fetch(descriptor)) ?? []
            if existingFavorites.contains(where: { $0.song.id == song.id }) {
                logger.info("Song already in favorites")
                return
            }
            
            // 创建新的 Song 实例
            let newSong = Song(
                id: song.id,
                title: song.title,
                artist: song.artist,
                album: song.album,
                genre: song.genre,
                releaseDate: song.releaseDate,
                duration: song.duration,
                songDescription: song.songDescription,
                kind: song.kind,
                license: song.license,
                permalink: song.permalink,
                permalinkUrl: song.permalinkUrl,
                permalinkImage: song.permalinkImage,
                caption: song.caption,
                downloadUrl: song.downloadUrl,
                fullDuration: song.fullDuration,
                likesCount: song.likesCount,
                playbackCount: song.playbackCount,
                tagList: song.tagList
            )
            
            let favorite = Favorite(song: newSong)
            modelContext.insert(favorite)
            
            do {
                try modelContext.save()
                logger.info("Successfully added to favorites")
                NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
            } catch {
                logger.error("Failed to add favorite: \(error.localizedDescription)")
            }
            
            fetchFavorites()
        }
    }
    
    func removeFavorite(_ favorite: Favorite) {
        Task { @MainActor in
            logger.info("Removing song from favorites: \(favorite.song.title)")
            modelContext.delete(favorite)
            
            do {
                try modelContext.save()
                logger.info("Successfully removed from favorites")
                NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
            } catch {
                logger.error("Failed to remove favorite: \(error.localizedDescription)")
            }
            
            fetchFavorites()
        }
    }
    
    func isFavorite(_ song: Song) -> Bool {
        logger.debug("Checking favorite status for song: \(song.title)")
        return favorites.contains { $0.song.id == song.id }
    }
    
    static let favoritesChangedNotification = Notification.Name("FavoritesChanged")
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
