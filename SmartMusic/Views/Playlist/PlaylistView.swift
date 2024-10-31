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
                if viewModel.playlists.isEmpty {
                    Text(NSLocalizedString("playlist.empty", comment: ""))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.playlists) { playlist in
                        NavigationLink(destination: PlaylistDetailView(playlist: playlist, modelContext: modelContext)) {
                            PlaylistRow(playlist: playlist)
                        }
                        .onAppear {
                            logger.debug("Displaying playlist: \(playlist.name)")
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tab.playlist", comment: ""))
            .toolbar {
                Button(action: {
                    logger.info("User tapped create playlist button")
                    viewModel.showCreatePlaylist = true
                }) {
                    Text(NSLocalizedString("playlist.create", comment: ""))
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
