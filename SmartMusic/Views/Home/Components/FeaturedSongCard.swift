import SwiftUI

struct FeaturedSongCard: View {
    let song: Song
    let onTap: () -> Void
    private let logger = LogService.shared
    
    var body: some View {
        AsyncImage(url: URL(string: song.albumCover)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .foregroundColor(.gray.opacity(0.2))
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            VStack(alignment: .leading) {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        )
        .padding(.horizontal)
        .onTapGesture {
            onTap()
        }
    }
}
