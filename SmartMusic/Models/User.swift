import Foundation
import SwiftData

@Model
class User {
    var id: String
    var username: String
    var avatar: String?
    var favoriteCount: Int
    var playlistCount: Int
    var historyCount: Int
    
    init(id: String = UUID().uuidString,
         username: String,
         avatar: String? = nil,
         favoriteCount: Int = 0,
         playlistCount: Int = 0,
         historyCount: Int = 0) {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.favoriteCount = favoriteCount
        self.playlistCount = playlistCount
        self.historyCount = historyCount
    }
}
