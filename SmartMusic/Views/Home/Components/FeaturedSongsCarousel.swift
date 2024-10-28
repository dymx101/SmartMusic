import SwiftUI

struct FeaturedSongsCarousel: View {
    let songs: [Song]
    @State private var currentIndex = 0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                FeaturedSongCard(song: song)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}
