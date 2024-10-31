import SwiftUI

struct YouTubeMusicView: View {
    @StateObject private var viewModel = YouTubeMusicViewModel()
    @State private var selectedVideoId: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 搜索栏
                    searchBar
                    
                    // 热门视频横向滚动区域
                    if !viewModel.trendingVideos.isEmpty {
                        VStack(alignment: .leading) {
                            Text("热门推荐")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.trendingVideos) { video in
                                        YouTubeTrendingCard(video: video)
                                            .onTapGesture {
                                                selectedVideoId = video.id
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 分类标签
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["全部", "音乐", "现场", "翻唱", "MV"], id: \.self) { category in
                                CategoryTag(title: category, 
                                          isSelected: viewModel.selectedCategory == category)
                                    .onTapGesture {
                                        viewModel.selectedCategory = category
                                        Task {
                                            await viewModel.fetchVideos()
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 视频网格列表
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.videos) { video in
                            YouTubeVideoCard(video: video)
                                .onTapGesture {
                                    selectedVideoId = video.id
                                }
                        }
                    }
                    .padding(.horizontal)
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
                .foregroundColor(.gray)
            
            TextField("搜索视频", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .onSubmit {
                    Task {
                        await viewModel.searchVideos()
                    }
                }
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// 分类标签组件
struct CategoryTag: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
    }
}

// 热门视频卡片
struct YouTubeTrendingCard: View {
    let video: YouTubeVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
            }
            .frame(width: 280, height: 157)
            .cornerRadius(12)
            .clipped()
            
            Text(video.title)
                .font(.headline)
                .lineLimit(2)
                .frame(width: 280, alignment: .leading)
            
            Text(video.channelTitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// 视频卡片
struct YouTubeVideoCard: View {
    let video: YouTubeVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
            }
            .cornerRadius(12)
            .clipped()
            
            Text(video.title)
                .font(.subheadline)
                .lineLimit(2)
            
            Text(video.channelTitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct VideoIdentifier: Identifiable {
    let id: String
} 
