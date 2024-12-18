import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var configManager = AppConfigManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                if configManager.shouldEnableFullAccess {
                    HomeView(modelContext: modelContext)
                        .tabItem {
                            Label(NSLocalizedString("tab.home", comment: ""), systemImage: "house.fill")
                        }
                    
                    SearchView()
                        .tabItem {
                            Label(NSLocalizedString("tab.search", comment: ""), systemImage: "magnifyingglass")
                        }
                }
                
                // YouTube tab
                YouTubeMusicView()
                    .tabItem {
                        Label(NSLocalizedString("tab.youtube", comment: ""), systemImage: "play.square.fill")
                    }
                
                // Playlist tab moved after YouTube
                if configManager.shouldEnableFullAccess {
                    PlaylistView(modelContext: modelContext)
                        .tabItem {
                            Label(NSLocalizedString("tab.playlist", comment: ""), systemImage: "music.note.list")
                        }
                }
                
                // Profile tab remains last
                ProfileView(modelContext: modelContext)
                    .tabItem {
                        Label(NSLocalizedString("tab.profile", comment: ""), systemImage: "person.fill")
                    }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 60)
            }
            
            VStack(spacing: 0) {
                MiniPlayerView(modelContext: modelContext)
                    .background(Color(.systemBackground))
                
                Divider()
                
                Color.clear
                    .frame(height: UITabBarController().tabBar.frame.height)
            }
        }
    }
}
