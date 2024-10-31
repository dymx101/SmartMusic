import SwiftUI
import SwiftData

struct MiniPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PlayerViewModel
    @State private var showFullPlayer = false
    @State private var showPlaylist = false
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        if let song = viewModel.currentSong {
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: song.albumCover)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                                .frame(width: 32, height: 32)
                            
                            Circle()
                                .trim(from: 0, to: viewModel.currentTime / viewModel.duration)
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(width: 32, height: 32)
                                .rotationEffect(.degrees(-90))
                            
                            Button(action: { viewModel.togglePlayPause() }) {
                                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title3)
                            }
                        }
                        
                        Button(action: { viewModel.playNext() }) {
                            Image(systemName: "forward.end.fill")
                                .font(.title3)
                        }
                        
                        Button(action: { showPlaylist.toggle() }) {
                            Image(systemName: "music.note.list")
                                .font(.title3)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .onTapGesture {
                    showFullPlayer = true
                }
            }
            .sheet(isPresented: $showFullPlayer) {
                PlayerView(modelContext: modelContext)
            }
            .sheet(isPresented: $showPlaylist) {
                PlaylistSheet(viewModel: viewModel)
                    .presentationDetents([.fraction(0.67)])
            }
        }
    }
}
