import SwiftUI
import SwiftData

struct GenreSongsView: View {
    @StateObject private var viewModel: GenreSongsViewModel
    @Environment(\.modelContext) private var modelContext
    @StateObject private var playerViewModel: PlayerViewModel
    private let logger = LogService.shared
    
    init(genreTitle: String, modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: GenreSongsViewModel(genreTitle: genreTitle))
        _playerViewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isGridView {
                gridContent
            } else {
                listContent
            }
        }
        .navigationTitle("歌曲列表")
        .toolbar {
            Button(action: { viewModel.toggleViewMode() }) {
                Image(systemName: viewModel.isGridView ? "list.bullet" : "square.grid.2x2")
            }
        }
        .task {
            await viewModel.fetchSongs()
        }
        .refreshable {
            await viewModel.fetchSongs(forceRefresh: true)
        }
    }
    
    // 网格视图
    private var gridContent: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(viewModel.songs, id: \.id) { song in
                SongGridItem(song: song) {
                    playerViewModel.playSong(song)
                }
            }
        }
        .padding()
    }
    
    // 列表视图
    private var listContent: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.songs, id: \.id) { song in
                SongListRow(
                    song: song,
                    onPlay: {
                        playerViewModel.playSong(song)
                    },
                    modelContext: modelContext
                )
                .padding(.horizontal)
                .onAppear {
                    if song == viewModel.songs.last {
                        Task {
                            await viewModel.fetchSongs()
                        }
                    }
                }
            }
        }
    }
}

// 网格项组件
struct SongGridItem: View {
    let song: Song
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: song.albumCover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(song.title)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
} 