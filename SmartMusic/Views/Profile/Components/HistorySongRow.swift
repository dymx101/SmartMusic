import SwiftUI

struct HistorySongRow: View {
    let history: PlayHistory
    let onPlay: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: history.song.albumCover)) { image in
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
                Text(history.song.title)
                    .font(.body)
                
                HStack {
                    Text(history.song.artist)
                    Text("·")
                    Text("播放\(history.playCount)次")
                }
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
