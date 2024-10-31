import SwiftUI
import SwiftData

struct AddSongsSheet: View {
    let playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    private let logger = LogService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("选择来源", selection: $selectedTab) {
                    Text("我的收藏").tag(0)
                    Text("播放历史").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    FavoritesList(playlist: playlist, playlistViewModel: viewModel)
                } else {
                    HistoryList(playlist: playlist, playlistViewModel: viewModel)
                }
            }
            .navigationTitle("添加歌曲")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 收藏列表
private struct FavoritesList: View {
    let playlist: Playlist
    @ObservedObject var playlistViewModel: PlaylistViewModel
    @StateObject private var favoritesViewModel: FavoritesViewModel
    
    init(playlist: Playlist, playlistViewModel: PlaylistViewModel) {
        self.playlist = playlist
        self.playlistViewModel = playlistViewModel
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(modelContext: playlistViewModel.context))
    }
    
    var body: some View {
        List {
            ForEach(favoritesViewModel.favorites) { favorite in
                HStack {
                    FavoriteSongRow(
                        song: favorite.song,
                        onPlay: {},
                        onRemove: {}
                    )
                    
                    if !playlist.songs.contains(where: { $0.id == favorite.song.id }) {
                        Button(action: {
                            playlistViewModel.addSongToPlaylist(favorite.song, playlist: playlist)
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
        }
        .onAppear {
            favoritesViewModel.fetchFavorites()
        }
    }
}

// 历史记录列表
private struct HistoryList: View {
    let playlist: Playlist
    @ObservedObject var playlistViewModel: PlaylistViewModel
    @StateObject private var historyViewModel: HistoryViewModel
    
    init(playlist: Playlist, playlistViewModel: PlaylistViewModel) {
        self.playlist = playlist
        self.playlistViewModel = playlistViewModel
        _historyViewModel = StateObject(wrappedValue: HistoryViewModel(modelContext: playlistViewModel.context))
    }
    
    var body: some View {
        List {
            ForEach(historyViewModel.history) { history in
                HStack {
                    HistorySongRow(
                        history: history,
                        onPlay: {}
                    )
                    
                    if !playlist.songs.contains(where: { $0.id == history.song.id }) {
                        Button(action: {
                            playlistViewModel.addSongToPlaylist(history.song, playlist: playlist)
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
        }
        .onAppear {
            historyViewModel.fetchHistory()
        }
    }
} 