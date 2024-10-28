import Foundation
import SwiftData

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var history: [PlayHistory] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchHistory()
    }
    
    func fetchHistory() {
        logger.info("Fetching play history")
        let descriptor = FetchDescriptor<PlayHistory>(sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)])
        history = (try? modelContext.fetch(descriptor)) ?? []
        logger.info("Fetched \(history.count) history records")
    }
    
    func addToHistory(_ song: Song) {
        logger.info("Adding song to history: \(song.title)")
        
        if let existingHistory = history.first(where: { $0.song.id == song.id }) {
            existingHistory.playCount += 1
            existingHistory.lastPlayedAt = Date()
            logger.info("Updated existing history entry, play count: \(existingHistory.playCount)")
        } else {
            let playHistory = PlayHistory(song: song)
            modelContext.insert(playHistory)
            logger.info("Created new history entry")
        }
        
        do {
            try modelContext.save()
            logger.info("Successfully saved history")
        } catch {
            logger.error("Failed to save history: \(error.localizedDescription)")
        }
        
        fetchHistory()
    }
    
    func clearHistory() {
        logger.info("Clearing all play history")
        history.forEach { modelContext.delete($0) }
        
        do {
            try modelContext.save()
            logger.info("Successfully cleared history")
        } catch {
            logger.error("Failed to clear history: \(error.localizedDescription)")
        }
        
        fetchHistory()
    }
}
