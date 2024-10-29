import Foundation
import SwiftData

@Model
final class Song: Codable {
    var id: Int
    var title: String
    var artist: String
    var album: String?
    var genre: String?
    var releaseDate: String?
    var duration: Int
    var songDescription: String?
    var kind: String?
    var license: String?
    var permalink: String?
    var permalinkUrl: String?
    var permalinkImage: String?
    var caption: String?
    var downloadUrl: String?
    var fullDuration: Int?
    var likesCount: Int?
    var playbackCount: Int?
    var tagList: String?
    
    // 添加计算属性来提供必要的URL
    var albumCover: String {
        permalinkImage ?? "https://picsum.photos/200"
    }
    
    var url: String {
        permalinkUrl ?? ""
    }
    
    init(id: Int, 
         title: String, 
         artist: String, 
         album: String? = nil, 
         genre: String? = nil, 
         releaseDate: String? = nil, 
         duration: Int,
         songDescription: String? = nil,
         kind: String? = nil,
         license: String? = nil,
         permalink: String? = nil,
         permalinkUrl: String? = nil,
         permalinkImage: String? = nil,
         caption: String? = nil,
         downloadUrl: String? = nil,
         fullDuration: Int? = nil,
         likesCount: Int? = nil,
         playbackCount: Int? = nil,
         tagList: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.genre = genre
        self.releaseDate = releaseDate
        self.duration = duration
        self.songDescription = songDescription
        self.kind = kind
        self.license = license
        self.permalink = permalink
        self.permalinkUrl = permalinkUrl
        self.permalinkImage = permalinkImage
        self.caption = caption
        self.downloadUrl = downloadUrl
        self.fullDuration = fullDuration
        self.likesCount = likesCount
        self.playbackCount = playbackCount
        self.tagList = tagList
    }
    
    // 处理 API 返回的 snake_case 字段名
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case album
        case genre
        case releaseDate = "release_date"
        case duration
        case songDescription = "description"
        case kind
        case license
        case permalink
        case permalinkUrl = "permalink_url"
        case permalinkImage = "permalink_image"
        case caption
        case downloadUrl = "download_url"
        case fullDuration = "full_duration"
        case likesCount = "likes_count"
        case playbackCount = "playback_count"
        case tagList = "tag_list"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        album = try container.decodeIfPresent(String.self, forKey: .album)
        genre = try container.decodeIfPresent(String.self, forKey: .genre)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        duration = try container.decode(Int.self, forKey: .duration)
        songDescription = try container.decodeIfPresent(String.self, forKey: .songDescription)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        license = try container.decodeIfPresent(String.self, forKey: .license)
        permalink = try container.decodeIfPresent(String.self, forKey: .permalink)
        permalinkUrl = try container.decodeIfPresent(String.self, forKey: .permalinkUrl)
        permalinkImage = try container.decodeIfPresent(String.self, forKey: .permalinkImage)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        downloadUrl = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
        fullDuration = try container.decodeIfPresent(Int.self, forKey: .fullDuration)
        likesCount = try container.decodeIfPresent(Int.self, forKey: .likesCount)
        playbackCount = try container.decodeIfPresent(Int.self, forKey: .playbackCount)
        tagList = try container.decodeIfPresent(String.self, forKey: .tagList)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encodeIfPresent(album, forKey: .album)
        try container.encodeIfPresent(genre, forKey: .genre)
        try container.encodeIfPresent(releaseDate, forKey: .releaseDate)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(songDescription, forKey: .songDescription)
        try container.encodeIfPresent(kind, forKey: .kind)
        try container.encodeIfPresent(license, forKey: .license)
        try container.encodeIfPresent(permalink, forKey: .permalink)
        try container.encodeIfPresent(permalinkUrl, forKey: .permalinkUrl)
        try container.encodeIfPresent(permalinkImage, forKey: .permalinkImage)
        try container.encodeIfPresent(caption, forKey: .caption)
        try container.encodeIfPresent(downloadUrl, forKey: .downloadUrl)
        try container.encodeIfPresent(fullDuration, forKey: .fullDuration)
        try container.encodeIfPresent(likesCount, forKey: .likesCount)
        try container.encodeIfPresent(playbackCount, forKey: .playbackCount)
        try container.encodeIfPresent(tagList, forKey: .tagList)
    }
}
