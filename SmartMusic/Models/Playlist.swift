import Foundation
import SwiftData

@Model
final class Playlist {
    var id: String
    var name: String
    var songs: [Song]
    var createdAt: Date
    
    init(id: String = UUID().uuidString, name: String, songs: [Song] = []) {
        self.id = id
        self.name = name
        self.songs = songs
        self.createdAt = Date()
    }
}
