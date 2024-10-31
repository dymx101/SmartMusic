import SwiftUI
import SwiftData

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
            .navigationTitle(NSLocalizedString("app.name", comment: ""))
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
                    songs: viewModel.recommendedSongs,
                    onSongTap: { song in
                        logger.info("User tapped featured song: \(song.title)")
                        playerViewModel.playSong(song, fromQueue: viewModel.recommendedSongs)
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
                Text(NSLocalizedString("home.myFavorites", comment: ""))
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                if !favoritesViewModel.favorites.isEmpty {
                    NavigationLink(NSLocalizedString("home.viewAll", comment: "")) {
                        FavoritesView(modelContext: modelContext)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            if favoritesViewModel.favorites.isEmpty {
                Text(NSLocalizedString("home.noFavorites", comment: ""))
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
                                        onPlay: { 
                                            let favoriteSongs = favoritesViewModel.favorites.map { $0.song }
                                            playerViewModel.playSong(favorite.song, fromQueue: favoriteSongs)
                                        },
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
                Text(NSLocalizedString("home.genres", comment: ""))
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.genres.isEmpty {
                Text(NSLocalizedString("home.noGenres", comment: ""))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.genres) { genre in
                            NavigationLink(destination: GenreSongsView(genreTitle: genre.title, modelContext: modelContext)) {
                                VStack(spacing: 8) {
                                    AsyncImage(url: URL(string: genre.imageLargeLight)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .foregroundColor(.gray.opacity(0.2))
                                    }
                                    .frame(height: 120)
                                    .frame(width: 200)
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
                    }
                    .padding(.horizontal)
                }
                .frame(height: 160)
            }
        }
        .padding(.vertical)
    }
    
    // 更多推荐部分
    private var recommendedSongsSection: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("home.moreRecommended", comment: ""))
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                // 获取除了前6首以外的推荐歌曲
                let remainingSongs = Array(viewModel.recommendedSongs.dropFirst(6))
                ForEach(remainingSongs) { song in
                    SongListRow(
                        song: song,
                        onPlay: {
                            logger.info("Playing song: \(song.title)")
                            // 使用剩余的推荐歌曲作为播放队列
                            playerViewModel.playSong(song, fromQueue: remainingSongs)
                        },
                        modelContext: modelContext
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
}

// 加数组扩展来支持分块
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
