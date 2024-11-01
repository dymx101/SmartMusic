import SwiftUI
import SwiftData

@main
struct SmartMusicApp: App {
    let container: ModelContainer
    @State private var showLaunchScreen = true
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
            ZStack {
                ContentView()
                    .modelContainer(container)
                    .opacity(showLaunchScreen ? 0 : 1)
                
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .onAppear {
                            logger.info("Launch screen appeared")
                            // 2秒后隐藏启动屏幕
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showLaunchScreen = false
                                }
                                logger.info("Launch screen dismissed")
                            }
                        }
                }
            }
            .onAppear {
                logger.info("App launched successfully")
            }
        }
    }
}
