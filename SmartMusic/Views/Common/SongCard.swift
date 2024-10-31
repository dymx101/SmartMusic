import SwiftUI

struct SongCard: View {
    let song: Song
    let onPlay: () -> Void
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: song.albumCover)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
} 