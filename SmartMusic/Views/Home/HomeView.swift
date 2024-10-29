import SwiftUI
import SwiftData

// 歌曲列表行组件
struct SongListRow: View {
    let song: Song
    let onPlay: () -> Void
    let modelContext: ModelContext
    @State private var showFullPlayer = false
    private let logger = LogService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                logger.info("User tapped song row: \(song.title)")
                onPlay()
                showFullPlayer = true
            }) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: song.albumCover)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.title)
                            .font(.body)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }
            
            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
        .fullScreenCover(isPresented: $showFullPlayer) {
            PlayerView(modelContext: modelContext)
        }
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var playerViewModel: PlayerViewModel
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @State private var showFullPlayer = false
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        _playerViewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 推荐轮播图
                    featuredSongsSection
                    
                    // 我的收藏
                    favoritesSection
                    
                    // 音乐类型
                    genresSection
                    
                    // 更多推荐
                    recommendedSongsSection
                }
                .padding(.bottom, 60)
            }
            .navigationTitle("SmartMusic")
            .refreshable {
                logger.info("User triggered manual refresh")
                await viewModel.fetchRecommendedSongs(forceRefresh: true)
                favoritesViewModel.fetchFavorites()
            }
            .onAppear {
                if favoritesViewModel.favorites.isEmpty {
                    favoritesViewModel.fetchFavorites()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .fullScreenCover(isPresented: $showFullPlayer) {
                PlayerView(modelContext: modelContext)
            }
        }
        .task {
            if viewModel.recommendedSongs.isEmpty {
                logger.info("Initial fetch of recommended songs")
                await viewModel.fetchRecommendedSongs()
            }
        }
    }
    
    // 推荐轮播图部分
    private var featuredSongsSection: some View {
        Group {
            if !viewModel.recommendedSongs.isEmpty {
                FeaturedSongsCarousel(
                    songs: Array(viewModel.recommendedSongs.prefix(6)),
                    onSongTap: { song in
                        logger.info("User tapped featured song: \(song.title)")
                        playerViewModel.playSong(song)
                        showFullPlayer = true
                    }
                )
                .frame(height: 200)
            }
        }
    }
    
    // 收藏部分
    private var favoritesSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("我的收藏")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                if !favoritesViewModel.favorites.isEmpty {
                    NavigationLink("查看全部") {
                        FavoritesView(modelContext: modelContext)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            if favoritesViewModel.favorites.isEmpty {
                Text("还没有收藏的歌曲")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 16) {
                        let columns = favoritesViewModel.favorites.chunked(into: 3)
                        ForEach(Array(columns.enumerated()), id: \.offset) { index, chunk in
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(chunk) { favorite in
                                    FavoriteSongRow(
                                        song: favorite.song,
                                        onPlay: { playerViewModel.playSong(favorite.song) },
                                        onRemove: { favoritesViewModel.removeFavorite(favorite) }
                                    )
                                    .frame(width: UIScreen.main.bounds.width - 32)
                                    .frame(height: 70)
                                }
                                
                                if chunk.count < 3 {
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollTargetBehavior(.paging)
            }
        }
        .padding(.vertical)
    }
    
    // 音乐类型部分
    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("音乐类型")
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.genres.isEmpty {
                Text("暂无音乐类型")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.genres) { genre in
                            VStack(spacing: 8) {
                                AsyncImage(url: URL(string: genre.imageLargeLight)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.gray.opacity(0.2))
                                }
                                .frame(height: 150)
                                .frame(width: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Text(genre.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                            }
                            .frame(width: 200)
                            .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 220)
            }
        }
        .padding(.vertical)
    }
    
    // 更多推荐部分
    private var recommendedSongsSection: some View {
        VStack(alignment: .leading) {
            Text("更多推荐")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(viewModel.recommendedSongs.dropFirst(6))) { song in
                    SongListRow(
                        song: song,
                        onPlay: {
                            logger.info("Playing song: \(song.title)")
                            playerViewModel.playSong(song)
                        },
                        modelContext: modelContext
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
}

// 添加数组扩展来支持分块
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
