import SwiftUI

struct FavoriteSongRow: View {
    let song: Song
    let onPlay: () -> Void
    let onRemove: () -> Void
    private let logger = LogService.shared
    
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
            .onAppear {
                logger.debug("Loading album cover for favorite song: \(song.title)")
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.body)
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                logger.info("Playing favorite song: \(song.title)")
                onPlay()
            }) {
                Image(systemName: "play.fill")
                    .font(.title3)
            }
            
            Button(action: {
                logger.info("Removing song from favorites: \(song.title)")
                onRemove()
            }) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
