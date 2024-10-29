import SwiftUI

struct FeaturedSongsCarousel: View {
    let songs: [Song]
    let onSongTap: (Song) -> Void
    private let logger = LogService.shared
    
    var body: some View {
        TabView {
            ForEach(songs) { song in
                FeaturedSongCard(
                    song: song,
                    onTap: {
                        logger.info("User tapped featured song: \(song.title)")
                        onSongTap(song)
                    }
                )
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
