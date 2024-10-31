import SwiftUI

struct YouTubePlayerView: View {
    let videoId: String
    @StateObject private var playerViewModel = YouTubePlayerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // YouTube 播放器
                YouTubeWebView(videoId: videoId)
                    .frame(height: UIScreen.main.bounds.width * 9/16)
                
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
    }
} 