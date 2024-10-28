import Foundation
import SwiftData

@Model
class PlayHistory {
    var id: String
    var song: Song
    var playCount: Int
    var lastPlayedAt: Date
    
    init(id: String = UUID().uuidString, song: Song) {
        self.id = id
        self.song = song
        self.playCount = 1
        self.lastPlayedAt = Date()
    }
}
