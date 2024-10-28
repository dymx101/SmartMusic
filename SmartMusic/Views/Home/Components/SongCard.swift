import SwiftUI

struct SongCard: View {
    let song: Song
    private let logger = LogService.shared
    
    var body: some View {
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
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onAppear {
                logger.debug("Loading album cover for song card: \(song.title)")
            }
            
            VStack(alignment: .leading, spacing: 4) {
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
        .onTapGesture {
            logger.info("User tapped song card: \(song.title)")
        }
    }
}
