import SwiftUI

struct YouTubeMusicView: View {
    @StateObject private var viewModel = YouTubeMusicViewModel()
    @State private var selectedVideoId: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 搜索栏
                    searchBar
                    
                    // 视频列表
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.videos) { video in
                            YouTubeVideoCard(video: video)
                                .onTapGesture {
                                    selectedVideoId = video.id
                                }
                        }
                    }
                }
            }
            .navigationTitle("YouTube Music")
            .sheet(item: Binding(
                get: { selectedVideoId.map { VideoIdentifier(id: $0) } },
                set: { selectedVideoId = $0?.id }
            )) { identifier in
                YouTubePlayerView(videoId: identifier.id)
            }
            .refreshable {
                await viewModel.fetchVideos()
            }
            .task {
                await viewModel.fetchVideos()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("搜索视频", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .onSubmit {
                    Task {
                        await viewModel.searchVideos()
                    }
                }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// 用于支持 sheet 的 Identifiable 包装器
struct VideoIdentifier: Identifiable {
    let id: String
} 