import Foundation
import Combine
import SwiftData

@MainActor
class PlayerViewModel: ObservableObject {
    @Published var currentSong: Song?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isFavorite = false
    
    private let audioPlayer = AudioPlayer.shared
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        audioPlayer.setModelContext(modelContext)
        setupBindings()
    }
    
    private func setupBindings() {
        audioPlayer.$currentSong
            .sink { [weak self] song in
                self?.currentSong = song
                self?.checkFavoriteStatus()
            }
            .store(in: &cancellables)
        
        audioPlayer.$isPlaying
            .assign(to: &$isPlaying)
        
        audioPlayer.$currentTime
            .assign(to: &$currentTime)
        
        audioPlayer.$duration
            .assign(to: &$duration)
    }
    
    func playSong(_ song: Song) {
        logger.info("Playing song: \(song.title)")
        audioPlayer.play(song)
    }
    
    func togglePlayPause() {
        logger.debug("Toggle play/pause")
        audioPlayer.togglePlayPause()
    }
    
    func seek(to time: Double) {
        audioPlayer.seek(to: time)
    }
    
    func toggleFavorite() {
        guard let song = currentSong else {
            logger.warning("No current song to favorite")
            return
        }
        logger.info("Toggling favorite status for song: \(song.title)")
        
        let descriptor = FetchDescriptor<Favorite>()
        let favorites = (try? modelContext.fetch(descriptor)) ?? []
        let existingFavorite = favorites.first { $0.song.id == song.id }
        
        if let favorite = existingFavorite {
            modelContext.delete(favorite)
            isFavorite = false
            logger.info("Removed song from favorites")
        } else {
            let favorite = Favorite(song: song)
            modelContext.insert(favorite)
            isFavorite = true
            logger.info("Added song to favorites")
        }
        
        try? modelContext.save()
    }
    
    private func checkFavoriteStatus() {
        guard let song = currentSong else {
            isFavorite = false
            return
        }
        
        let descriptor = FetchDescriptor<Favorite>()
        let favorites = (try? modelContext.fetch(descriptor)) ?? []
        isFavorite = favorites.contains { $0.song.id == song.id }
    }
}
