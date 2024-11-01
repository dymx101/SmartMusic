import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FavoritesViewModel
    @StateObject private var playerViewModel: PlayerViewModel
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(modelContext: modelContext))
        _playerViewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.favorites) { favorite in
                FavoriteSongRow(
                    song: favorite.song,
                    onPlay: {
                        logger.info("Playing favorite song: \(favorite.song.title)")
                        let favoriteSongs = viewModel.favorites.map { $0.song }
                        playerViewModel.playSong(favorite.song, fromQueue: favoriteSongs)
                    },
                    onRemove: {
                        logger.info("Removing song from favorites: \(favorite.song.title)")
                        viewModel.removeFavorite(favorite)
                    }
                )
            }
        }
        .navigationTitle(NSLocalizedString("profile.favorites", comment: ""))
        .overlay {
            if viewModel.favorites.isEmpty {
                ContentUnavailableView(
                    NSLocalizedString("favorites.empty.title", comment: ""),
                    systemImage: "heart.slash",
                    description: Text(NSLocalizedString("favorites.empty.description", comment: ""))
                )
            }
        }
        .onAppear {
            logger.info("Favorites view appeared")
        }
    }
}
