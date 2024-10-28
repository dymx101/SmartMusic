import Foundation

struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let albumCover: String
    let duration: Int
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case albumCover = "album_cover"
        case duration
        case url
    }
}
