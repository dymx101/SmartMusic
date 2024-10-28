import Foundation
import SwiftData

@MainActor
class PlaylistViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var showCreatePlaylist = false
    @Published var newPlaylistName = ""
    
    private let modelContext: ModelContext
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchPlaylists()
    }
    
    func fetchPlaylists() {
        logger.info("Fetching playlists")
        let descriptor = FetchDescriptor<Playlist>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        playlists = (try? modelContext.fetch(descriptor)) ?? []
        logger.info("Fetched \(playlists.count) playlists")
    }
    
    func createPlaylist() {
        guard !newPlaylistName.isEmpty else {
            logger.warning("Attempted to create playlist with empty name")
            return
        }
        
        logger.info("Creating new playlist: \(newPlaylistName)")
        let playlist = Playlist(name: newPlaylistName)
        modelContext.insert(playlist)
        
        do {
            try modelContext.save()
            logger.info("Successfully created playlist: \(newPlaylistName)")
        } catch {
            logger.error("Failed to save playlist: \(error.localizedDescription)")
        }
        
        newPlaylistName = ""
        showCreatePlaylist = false
        fetchPlaylists()
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        logger.info("Deleting playlist: \(playlist.name)")
        modelContext.delete(playlist)
        
        do {
            try modelContext.save()
            logger.info("Successfully deleted playlist")
        } catch {
            logger.error("Failed to delete playlist: \(error.localizedDescription)")
        }
        
        fetchPlaylists()
    }
    
    func addSongToPlaylist(_ song: Song, playlist: Playlist) {
        logger.info("Adding song '\(song.title)' to playlist '\(playlist.name)'")
        playlist.songs.append(song)
        
        do {
            try modelContext.save()
            logger.info("Successfully added song to playlist")
        } catch {
            logger.error("Failed to add song to playlist: \(error.localizedDescription)")
        }
        
        fetchPlaylists()
    }
    
    func removeSongFromPlaylist(_ song: Song, playlist: Playlist) {
        logger.info("Removing song '\(song.title)' from playlist '\(playlist.name)'")
        playlist.songs.removeAll { $0.id == song.id }
        
        do {
            try modelContext.save()
            logger.info("Successfully removed song from playlist")
        } catch {
            logger.error("Failed to remove song from playlist: \(error.localizedDescription)")
        }
        
        fetchPlaylists()
    }
}
