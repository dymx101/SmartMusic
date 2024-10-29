import SwiftUI
import SwiftData

struct PlaylistView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PlaylistViewModel
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: PlaylistViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.playlists) { playlist in
                    NavigationLink(destination: PlaylistDetailView(playlist: playlist, modelContext: modelContext)) {
                        PlaylistRow(playlist: playlist)
                    }
                    .onAppear {
                        logger.debug("Displaying playlist: \(playlist.name)")
                    }
                }
                .onDelete { indexSet in
                    logger.info("Deleting playlists at indices: \(indexSet)")
                    indexSet.forEach { index in
                        viewModel.deletePlaylist(viewModel.playlists[index])
                    }
                }
            }
            .navigationTitle("播放列表")
            .toolbar {
                Button(action: {
                    logger.info("User tapped create playlist button")
                    viewModel.showCreatePlaylist = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showCreatePlaylist) {
                CreatePlaylistView(viewModel: viewModel)
            }
        }
        .onAppear {
            logger.info("PlaylistView appeared")
            viewModel.fetchPlaylists()
        }
    }
}
