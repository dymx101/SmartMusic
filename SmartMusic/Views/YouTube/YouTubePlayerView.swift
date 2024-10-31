import SwiftUI
import AVKit

struct YouTubePlayerView: View {
    let videoId: String
    @StateObject private var playerViewModel = YouTubePlayerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 视频播放器
                if let player = playerViewModel.player {
                    VideoPlayer(player: player)
                        .frame(height: UIScreen.main.bounds.width * 9/16)
                } else {
                    ProgressView()
                        .frame(height: UIScreen.main.bounds.width * 9/16)
                }
                
                // 视频信息
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(playerViewModel.videoTitle)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text(playerViewModel.channelTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        // 控制按钮
                        HStack(spacing: 40) {
                            Button(action: playerViewModel.togglePlayPause) {
                                Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title2)
                            }
                            
                            Button(action: playerViewModel.replay10Seconds) {
                                Image(systemName: "gobackward.10")
                                    .font(.title2)
                            }
                            
                            Button(action: playerViewModel.forward10Seconds) {
                                Image(systemName: "goforward.10")
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        // 视频描述
                        Text(playerViewModel.videoDescription)
                            .font(.body)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            playerViewModel.loadVideo(videoId: videoId)
        }
        .onDisappear {
            playerViewModel.cleanup()
        }
    }
} 