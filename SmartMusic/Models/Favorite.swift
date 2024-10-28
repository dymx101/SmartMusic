import Foundation
import SwiftData

@Model
class Favorite {
    var id: String
    var song: Song
    var createdAt: Date
    
    init(id: String = UUID().uuidString, song: Song) {
        self.id = id
        self.song = song
        self.createdAt = Date()
    }
}
