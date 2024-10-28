import SwiftUI

struct CreatePlaylistView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    @Environment(\.dismiss) private var dismiss
    private let logger = LogService.shared
    
    var body: some View {
        NavigationView {
            Form {
                TextField("播放列表名称", text: $viewModel.newPlaylistName)
                    .onChange(of: viewModel.newPlaylistName) { newValue in
                        logger.debug("Playlist name input changed: \(newValue)")
                    }
            }
            .navigationTitle("新建播放列表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        logger.info("User cancelled playlist creation")
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
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
