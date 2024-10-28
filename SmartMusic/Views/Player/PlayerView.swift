import SwiftUI
import SwiftData

struct PlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 顶部控制栏
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.title3)
                }
                
                Spacer()
                
                Text(viewModel.currentSong?.title ?? "")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { viewModel.toggleFavorite() }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(viewModel.isFavorite ? .red : .primary)
                }
            }
            .padding()
            
            Spacer()
            
            // 封面
            if let song = viewModel.currentSong {
                AsyncImage(url: URL(string: song.albumCover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(width: 300, height: 300)
                .cornerRadius(20)
            }
            
            Spacer()
            
            // 歌曲信息
            VStack(spacing: 8) {
                Text(viewModel.currentSong?.title ?? "")
                    .font(.title2)
                    .bold()
                
                Text(viewModel.currentSong?.artist ?? "")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // 进度条
            VStack {
                Slider(
                    value: Binding(
                        get: { viewModel.currentTime },
                        set: { viewModel.seek(to: $0) }
                    ),
                    in: 0...viewModel.duration
                )
                
                HStack {
                    Text(formatTime(viewModel.currentTime))
                    Spacer()
                    Text(formatTime(viewModel.duration))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            
            // 控制按钮
            HStack(spacing: 40) {
                Button(action: {}) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                
                Button(action: { viewModel.togglePlayPause() }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 65))
                }
                
                Button(action: {}) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
