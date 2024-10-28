import SwiftUI

struct PlaylistRow: View {
    let playlist: Playlist
    private let logger = LogService.shared
    
    var body: some View {
        HStack {
            PlaylistCover(songs: playlist.songs)
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .onAppear {
                    logger.debug("Loading playlist cover for: \(playlist.name)")
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.headline)
                
                Text("\(playlist.songs.count) 首歌曲")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PlaylistCover: View {
    let songs: [Song]
    private let logger = LogService.shared
    
    var body: some View {
        if songs.isEmpty {
            Image(systemName: "music.note.list")
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
        } else {
            AsyncImage(url: URL(string: songs[0].albumCover)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().foregroundColor(.gray.opacity(0.2))
            }
            .onAppear {
                logger.debug("Loading cover image for first song in playlist")
            }
        }
    }
}
