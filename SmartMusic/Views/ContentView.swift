import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView()
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
            
            MiniPlayerView(modelContext: modelContext)
        }
    }
}
