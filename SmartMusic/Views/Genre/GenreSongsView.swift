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
    
    private var gridContent: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 150), spacing: 16)
        ], spacing: 16) {
            ForEach(viewModel.songs) { song in
                SongCard(
                    song: song,
                    onPlay: {
                        logger.info("Playing song from grid: \(song.title)")
                        playerViewModel.playSong(song, fromQueue: viewModel.songs)
                    }
                )
            }
        }
        .padding()
    }
    
    private var listContent: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.songs) { song in
                SongListRow(
                    song: song,
                    onPlay: {
                        logger.info("Playing song from list: \(song.title)")
                        playerViewModel.playSong(song, fromQueue: viewModel.songs)
                    },
                    modelContext: modelContext
                )
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
