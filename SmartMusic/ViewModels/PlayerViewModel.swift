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
    private let playbackQueue = PlaybackQueue.shared
    private let logger = LogService.shared
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func playSong(_ song: Song, fromQueue queue: [Song]) {
        logger.info("Playing song: \(song.title) from queue with \(queue.count) songs")
        if let startIndex = queue.firstIndex(where: { $0.id == song.id }) {
            audioPlayer.play(song, queue: queue, startIndex: startIndex)
        } else {
            logger.warning("Song not found in queue, playing without queue context")
            audioPlayer.play(song)
        }
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
    
    var playModeIcon: String {
        switch playbackQueue.playMode {
        case .sequence:
            return "repeat"
        case .random:
            return "shuffle"
        case .single:
            return "repeat.1"
        }
    }
    
    func playNext() {
        logger.info("User requested next song")
        audioPlayer.playNext()
    }
    
    func playPrevious() {
        logger.info("User requested previous song")
        audioPlayer.playPrevious()
    }
    
    func togglePlayMode() {
        logger.info("User toggled play mode")
        playbackQueue.togglePlayMode()
    }
}
