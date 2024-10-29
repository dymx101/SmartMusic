import Foundation

struct Genre: Codable, Identifiable {
    let id = UUID()
    let title: String
    let imageLargeLight: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageLargeLight = "image_large_light"
    }
} 