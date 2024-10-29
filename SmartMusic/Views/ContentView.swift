import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView(modelContext: modelContext)
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }
                
                SearchView()
                    .tabItem {
                        Label("搜索", systemImage: "magnifyingglass")
                    }
                
                PlaylistView(modelContext: modelContext)
                    .tabItem {
                        Label("播放列表", systemImage: "music.note.list")
                    }
                
                ProfileView(modelContext: modelContext)
                    .tabItem {
                        Label("我的", systemImage: "person.fill")
                    }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 60) // 为底部播放器预留空间
            }
            
            VStack(spacing: 0) {
                MiniPlayerView(modelContext: modelContext)
                    .background(Color(.systemBackground))
                
                Divider()
                
                // TabBar 的高度
                Color.clear
                    .frame(height: UITabBarController().tabBar.frame.height)
            }
        }
    }
}
