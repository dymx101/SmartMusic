import SwiftUI

struct CreatePlaylistView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    @Environment(\.dismiss) private var dismiss
    private let logger = LogService.shared
    
    var body: some View {
        NavigationView {
            Form {
                TextField("playlist.create.name".localized, text: $viewModel.newPlaylistName)
                    .onChange(of: viewModel.newPlaylistName) { newValue in
                        logger.debug("Playlist name input changed: \(newValue)")
                    }
            }
            .navigationTitle("playlist.create.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) {
                        logger.info("User cancelled playlist creation")
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.create".localized) {
                        logger.info("Creating new playlist: \(viewModel.newPlaylistName)")
                        viewModel.createPlaylist()
                    }
                    .disabled(viewModel.newPlaylistName.isEmpty)
                }
            }
        }
        .onAppear {
            logger.info("Create playlist view appeared")
        }
    }
}
