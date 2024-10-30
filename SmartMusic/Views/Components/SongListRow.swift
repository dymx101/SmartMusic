import SwiftUI
import SwiftData

struct SongListRow: View {
    let song: Song
    let onPlay: () -> Void
    let modelContext: ModelContext
    @State private var showFullPlayer = false
    private let logger = LogService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                logger.info("User tapped song row: \(song.title)")
                onPlay()
                showFullPlayer = true
            }) {
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
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }
            
            Button(action: onPlay) {
                Image(systemName: "play.fill")
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
        .fullScreenCover(isPresented: $showFullPlayer) {
            PlayerView(modelContext: modelContext)
        }
    }
} 