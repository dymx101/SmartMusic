import Foundation

class YouTubeService {
    static let shared = YouTubeService()
    private let apiKey = "AIzaSyB7uDHRMPeV8tuzrRP1c7t5_hDcLC3rew8"  // 使用配置文件中的 API 密钥
    private let baseURL = "https://www.googleapis.com/youtube/v3"
    private let logger = LogService.shared
    
    private init() {}
    
    func searchMusic(query: String) async throws -> [Song] {
        let endpoint = "\(baseURL)/search"
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoCategoryId", value: "10"), // Music category
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "maxResults", value: "20")
        ]
        
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw SmartMusic.NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SmartMusic.NetworkError.invalidResponse
        }
        
        do {
            let searchResult = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
            return searchResult.items.map { item in
                let uniqueId = abs(item.id.videoId.hashValue)
                
                return Song(
                    id: uniqueId,
                    title: item.snippet.title,
                    artist: item.snippet.channelTitle,
                    album: "",
                    genre: "YouTube Music",
                    releaseDate: item.snippet.publishedAt,
                    duration: 0,
                    songDescription: item.snippet.description,
                    kind: "youtube#video",
                    license: "",
                    permalink: item.id.videoId,
                    permalinkUrl: "https://www.youtube.com/watch?v=\(item.id.videoId)",
                    permalinkImage: item.snippet.thumbnails.high.url,
                    caption: "",
                    downloadUrl: "",
                    fullDuration: 0,
                    likesCount: 0,
                    playbackCount: 0,
                    tagList: "youtube"
                )
            }
        } catch {
            logger.error("Failed to decode YouTube response: \(error)")
            throw SmartMusic.NetworkError.decodingError
        }
    }
    
    func getTrendingMusic() async throws -> [Song] {
        let endpoint = "\(baseURL)/videos"
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "chart", value: "mostPopular"),
            URLQueryItem(name: "videoCategoryId", value: "10"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "maxResults", value: "10")
        ]
        
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw SmartMusic.NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SmartMusic.NetworkError.invalidResponse
        }
        
        do {
            let searchResult = try JSONDecoder().decode(TrendingResponse.self, from: data)
            return searchResult.items.map { item in
                let uniqueId = abs(item.id.hashValue)
                
                return Song(
                    id: uniqueId,
                    title: item.snippet.title,
                    artist: item.snippet.channelTitle,
                    album: "",
                    genre: "YouTube Music",
                    releaseDate: item.snippet.publishedAt,
                    duration: 0,
                    songDescription: item.snippet.description,
                    kind: "youtube#video",
                    license: "",
                    permalink: item.id,
                    permalinkUrl: "https://www.youtube.com/watch?v=\(item.id)",
                    permalinkImage: item.snippet.thumbnails.high.url,
                    caption: "",
                    downloadUrl: "",
                    fullDuration: 0,
                    likesCount: 0,
                    playbackCount: 0,
                    tagList: "youtube"
                )
            }
        } catch {
            logger.error("Failed to decode YouTube trending response: \(error)")
            throw SmartMusic.NetworkError.decodingError
        }
    }
    
    func getVideoDetails(videoId: String) async throws -> VideoDetails {
        let endpoint = "\(baseURL)/videos"
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "id", value: videoId),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw SmartMusic.NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SmartMusic.NetworkError.invalidResponse
        }
        
        do {
            let result = try JSONDecoder().decode(VideoDetailsResponse.self, from: data)
            guard let videoDetails = result.items.first else {
                throw SmartMusic.NetworkError.noData
            }
            return VideoDetails(
                title: videoDetails.snippet.title,
                description: videoDetails.snippet.description,
                channelTitle: videoDetails.snippet.channelTitle
            )
        } catch {
            logger.error("Failed to decode video details: \(error)")
            throw SmartMusic.NetworkError.decodingError
        }
    }
}

// YouTube API 响应模型
struct YouTubeSearchResponse: Codable {
    let items: [YouTubeItem]
}

struct YouTubeItem: Codable {
    let id: VideoID
    let snippet: VideoSnippet
}

struct VideoID: Codable {
    let videoId: String
}

// 新增热门视频响应模型
struct TrendingResponse: Codable {
    let items: [TrendingItem]
}

struct TrendingItem: Codable {
    let id: String
    let snippet: VideoSnippet
}

struct VideoSnippet: Codable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnails
    let channelTitle: String
}

struct Thumbnails: Codable {
    let high: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
}

// 添加新的响应模型
struct VideoDetailsResponse: Codable {
    let items: [VideoDetailsItem]
}

struct VideoDetailsItem: Codable {
    let snippet: VideoSnippet
}

struct VideoDetails {
    let title: String
    let description: String
    let channelTitle: String
} 
