import SwiftUI
import SwiftData

struct YouTubeMusicCard: View {
    let song: Song
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: song.albumCover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(width: 150, height: 150)
                .cornerRadius(8)
                
                Text(song.title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 150)
        }
    }
}

struct YouTubePlaylistCard: View {
    let playlist: Playlist
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationLink(destination: PlaylistDetailView(playlist: playlist, modelContext: modelContext)) {
            VStack(alignment: .leading) {
                PlaylistCover(songs: playlist.songs)
                    .frame(width: 150, height: 150)
                    .cornerRadius(8)
                
                Text(playlist.name)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text("\(playlist.songs.count) 首歌曲")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 150)
        }
    }
}

struct YouTubeSongRow: View {
    let song: Song
    let onPlay: () -> Void
    
    var body: some View {
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
        .padding(.vertical, 4)
    }
} 