import SwiftUI
import SwiftData

struct PlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPlaylist = false
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 顶部控制栏
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                }
                
                Spacer()
                
                Button(action: { showPlaylist.toggle() }) {
                    Image(systemName: "music.note.list")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 唱片旋转动画
            ZStack {
                Circle()
                    .fill(.gray.opacity(0.1))
                    .frame(width: 280, height: 280)
                
                if let song = viewModel.currentSong {
                    AsyncImage(url: URL(string: song.albumCover)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(viewModel.isPlaying ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), 
                             value: viewModel.isPlaying)
                }
                
                // 唱臂
                Image("tonearm")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .rotationEffect(.degrees(viewModel.isPlaying ? -30 : -10))
                    .offset(x: 80, y: -80)
            }
            
            Spacer()
            
            // 歌曲信息
            if let song = viewModel.currentSong {
                VStack(spacing: 8) {
                    Text(song.title)
                        .font(.title2)
                        .bold()
                    Text(song.artist)
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度条
            VStack(spacing: 8) {
                Slider(value: $viewModel.currentTime, in: 0...viewModel.duration) { editing in
                    if !editing {
                        viewModel.seek(to: viewModel.currentTime)
                    }
                }
                
                HStack {
                    Text(formatTime(viewModel.currentTime))
                    Spacer()
                    Text(formatTime(viewModel.duration))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // 控制按钮
            HStack(spacing: 40) {
                Button(action: { viewModel.toggleFavorite() }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(viewModel.isFavorite ? .red : .primary)
                }
                
                Button(action: { viewModel.playPrevious() }) {
                    Image(systemName: "backward.end.fill")
                        .font(.title)
                }
                
                Button(action: { viewModel.togglePlayPause() }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                }
                
                Button(action: { viewModel.playNext() }) {
                    Image(systemName: "forward.end.fill")
                        .font(.title)
                }
                
                Button(action: { viewModel.togglePlayMode() }) {
                    Image(systemName: viewModel.playModeIcon)
                        .font(.title2)
                }
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showPlaylist) {
            PlaylistSheet(viewModel: viewModel)
                .presentationDetents([.fraction(0.67)])
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct PlaylistSheet: View {
    @ObservedObject var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.playbackQueue.currentQueue) { song in
                    HStack {
                        if song.id == viewModel.currentSong?.id {
                            Image(systemName: "music.note")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            viewModel.playSong(song, fromQueue: viewModel.playbackQueue.currentQueue)
                            dismiss()
                        }) {
                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .foregroundColor(.primary)
                                Text(song.artist)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("当前播放列表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}
