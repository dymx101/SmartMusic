import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FavoritesViewModel
    @StateObject private var playerViewModel = PlayerViewModel()
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.favorites) { favorite in
                FavoriteSongRow(
                    song: favorite.song,
                    onPlay: {
                        logger.info("Playing favorite song: \(favorite.song.title)")
                        playerViewModel.playSong(favorite.song)
                    },
                    onRemove: {
                        logger.info("Removing song from favorites: \(favorite.song.title)")
                        viewModel.removeFavorite(favorite)
                    }
                )
            }
        }
        .navigationTitle("我的收藏")
        .overlay {
            if viewModel.favorites.isEmpty {
                ContentUnavailableView(
                    "暂无收藏",
                    systemImage: "heart.slash",
                    description: Text("你还没有收藏任何歌曲")
                )
            }
        }
        .onAppear {
            logger.info("Favorites view appeared")
        }
    }
}
