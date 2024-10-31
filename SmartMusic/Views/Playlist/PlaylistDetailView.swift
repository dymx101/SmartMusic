import SwiftUI
import SwiftData

struct PlaylistDetailView: View {
    let playlist: Playlist
    @StateObject private var viewModel: PlayerViewModel
    @StateObject private var playlistViewModel: PlaylistViewModel
    @State private var showAddSongSheet = false
    private let logger = LogService.shared
    
    init(playlist: Playlist, modelContext: ModelContext) {
        self.playlist = playlist
        _viewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
        _playlistViewModel = StateObject(wrappedValue: PlaylistViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        List {
            ForEach(playlist.songs) { song in
                SongRow(
                    song: song,
                    onPlay: {
                        logger.info("Playing song '\(song.title)' from playlist '\(playlist.name)'")
                        viewModel.playSong(song, fromQueue: playlist.songs)
                    }
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        playlistViewModel.removeSongFromPlaylist(song, playlist: playlist)
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(playlist.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showAddSongSheet = true }) {
                        Label("添加歌曲", systemImage: "plus")
                    }
                    
                    Button(role: .destructive, action: {
                        logger.info("User requested to delete playlist: \(playlist.name)")
                        playlistViewModel.deletePlaylist(playlist)
                    }) {
                        Label("删除播放列表", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showAddSongSheet) {
            AddSongsSheet(playlist: playlist, viewModel: playlistViewModel)
        }
    }
}

struct SongRow: View {
    let song: Song
    let onPlay: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: song.albumCover)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
            }
            .frame(width: 40, height: 40)
            .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.body)
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .font(.title3)
            }
        }
    }
}
