import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
//    "app.name" = "SmartMusic";
//    "tab.home" = "Home";
//    "tab.search" = "Search";
//    "tab.playlist" = "Playlist";
//    "tab.profile" = "Profile";
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView(modelContext: modelContext)
                    .tabItem {
                        Label(NSLocalizedString("tab.home", comment: ""), systemImage: "house.fill")
                    }
                
                SearchView()
                    .tabItem {
                        Label(NSLocalizedString("tab.search", comment: ""), systemImage: "magnifyingglass")
                    }
                
                YouTubeMusicView()
                    .tabItem {
                        Label(NSLocalizedString("tab.youtube", comment: ""), systemImage: "play.square.fill")
                    }
                
                PlaylistView(modelContext: modelContext)
                    .tabItem {
                        Label(NSLocalizedString("tab.playlist", comment: ""), systemImage: "music.note.list")
                    }
                
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
