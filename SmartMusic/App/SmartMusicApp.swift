import SwiftUI
import SwiftData

@main
struct SmartMusicApp: App {
    let container: ModelContainer
    private let logger = LogService.shared
    
    init() {
        do {
            logger.info("Initializing ModelContainer")
            container = try ModelContainer(
                for: Playlist.self,
                User.self,
                Favorite.self,
                PlayHistory.self
            )
            logger.info("ModelContainer initialized successfully")
        } catch {
            logger.error("Failed to initialize ModelContainer: \(error.localizedDescription)")
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .onAppear {
                    logger.info("App launched successfully")
                }
        }
    }
}
