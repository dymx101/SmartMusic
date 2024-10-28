import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist
    @StateObject private var viewModel = PlayerViewModel()
    private let logger = LogService.shared
    
    var body: some View {
        List {
            ForEach(playlist.songs) { song in
                SongRow(song: song, onPlay: {
                    logger.info("Playing song '\(song.title)' from playlist '\(playlist.name)'")
                    viewModel.playSong(song)
                })
            }
        }
        .navigationTitle(playlist.name)
        .toolbar {
            Menu {
                Button(role: .destructive, action: {
                    logger.info("User requested to delete playlist: \(playlist.name)")
                }) {
                    Label("删除播放列表", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .onAppear {
            logger.info("Opened playlist: \(playlist.name)")
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
