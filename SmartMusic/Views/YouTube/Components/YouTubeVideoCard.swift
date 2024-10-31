import SwiftUI

struct YouTubeVideoCard: View {
    let video: YouTubeVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
            }
            .cornerRadius(8)
            
            Text(video.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(video.channelTitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
} 