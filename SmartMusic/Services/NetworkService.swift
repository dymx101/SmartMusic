import Foundation

//enum NetworkError: Error {
//    case invalidURL
//    case invalidResponse
//    case decodingError
//    case serverError(String)
//}

// 定义API响应的数据结构
struct APIResponse<T: Codable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
    
    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://34.71.190.229:8000"
    private let logger = LogService.shared
    
    private init() {}
    
    // 获取推荐歌曲
    func fetchRecommendedSongs(page: Int = 1, pageSize: Int = 20, query: String = "playback_count") async throws -> [Song] {
        logger.info("Fetching recommended songs - page: \(page), pageSize: \(pageSize), query: \(query)")
        let endpoint = "/music/local/recommend/songs/?page=\(page)&page_size=\(pageSize)&query=\(query)"
        
        guard let url = URL(string: baseURL + endpoint) else {
            logger.error("Invalid URL: \(baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // 打印原始响应数据以便调试
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("Raw response: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            logger.debug("Response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("Invalid response status: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }
            
            do {
                // 移除自动转换策略，使用 CodingKeys 手动处理
                let decoder = JSONDecoder()
                let response = try decoder.decode(APIResponse<Song>.self, from: data)
                
                // 验证每个歌曲对象的数据完整性
                for song in response.results {
                    logger.debug("""
                    Decoded song details:
                    - ID: \(song.id)
                    - Title: \(song.title)
                    - Artist: \(song.artist)
                    - Album: \(song.album ?? "N/A")
                    - Genre: \(song.genre ?? "N/A")
                    - Release Date: \(song.releaseDate ?? "N/A")
                    - Duration: \(song.duration)
                    - Description: \(song.songDescription ?? "N/A")
                    - Kind: \(song.kind ?? "N/A")
                    - License: \(song.license ?? "N/A")
                    - Permalink: \(song.permalink ?? "N/A")
                    - Permalink URL: \(song.permalinkUrl ?? "N/A")
                    - Permalink Image: \(song.permalinkImage ?? "N/A")
                    - Caption: \(song.caption ?? "N/A")
                    - Download URL: \(song.downloadUrl ?? "N/A")
                    - Full Duration: \(song.fullDuration ?? 0)
                    - Likes Count: \(song.likesCount ?? 0)
                    - Playback Count: \(song.playbackCount ?? 0)
                    - Tag List: \(song.tagList ?? "N/A")
                    """)
                }
                
                logger.info("Successfully decoded \(response.results.count) songs")
                return response.results
            } catch {
                logger.error("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        logger.error("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        logger.error("Value of type '\(type)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        logger.error("Type '\(type)' mismatch: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        logger.error("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        logger.error("Unknown decoding error: \(error.localizedDescription)")
                    }
                }
                throw NetworkError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
    
    // 获取精选歌曲
    func fetchFeaturedSongs() async throws -> [Song] {
        logger.info("Fetching featured songs")
        return try await fetch("/music/featured")
    }
    
    // 搜索歌曲
    func searchSongs(query: String, limit: Int = 20, offset: Int = 0) async throws -> [Song] {
        logger.info("Searching songs with query: \(query)")
        
        guard let url = URL(string: baseURL + "/music/soundcloud/search/") else {
            logger.error("Invalid search URL")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("hJEHv9Hx3xTxGNNEaOxvWeAFWeuWs21v48IEVfsLsMUBxVxrHPrYTMl1KIsS4tcI", forHTTPHeaderField: "X-CSRFTOKEN")
        
        let searchParams = ["q": query, "limit": limit, "offset": offset] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: searchParams)
        
        // 打印请求信息
        logger.debug("Request URL: \(url.absoluteString)")
        logger.debug("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            logger.debug("Request body: \(bodyString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 打印响应信息
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Response is not HTTPURLResponse")
            throw NetworkError.invalidResponse
        }
        
        logger.debug("Response status code: \(httpResponse.statusCode)")
        logger.debug("Response headers: \(httpResponse.allHeaderFields)")
        
        // 打印响应数据
        if let responseString = String(data: data, encoding: .utf8) {
            logger.debug("Response data: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        // 创建临时解码结构
        struct TempSong: Codable {
            let title: String
            let artist: String
            let album: String?
            let genre: String?
            let releaseDate: String?
            let duration: Int
            let songDescription: String?
            let kind: String?
            let license: String?
            let permalink: String?
            let permalinkUrl: String?
            let permalinkImage: String?
            let caption: String?
            let downloadUrl: String?
            let fullDuration: Int?
            let likesCount: Int?
            let playbackCount: Int?
            let tagList: String?
            
            enum CodingKeys: String, CodingKey {
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
            
        }
        
        do {
            let decoder = JSONDecoder()
            // 尝试解码并打印详细错误信息
            do {
                let tempSongs = try decoder.decode([TempSong].self, from: data)
                logger.info("Successfully decoded \(tempSongs.count) songs")
                
                // 打印第一个 tempSong 的详细信息用于调试
                if let firstSong = tempSongs.first {
                    logger.debug("""
                    First decoded TempSong:
                    - Title: \(firstSong.title)
                    - Artist: \(firstSong.artist)
                    - PermalinkUrl: \(firstSong.permalinkUrl ?? "N/A")
                    - Duration: \(firstSong.duration)
                    """)
                }
                
                // 转换为 Song 对象
                let songs = tempSongs.enumerated().map { index, tempSong -> Song in
                    // 基础ID从1000开始
                    // offset 表示已经跳过的数量
                    // index 是当前页中的索引
                    let id = 1000 + offset*limit + index
                    
                    let song = Song(
                        id: id,
                        title: tempSong.title,
                        artist: tempSong.artist,
                        album: tempSong.album,
                        genre: tempSong.genre,
                        releaseDate: tempSong.releaseDate,
                        duration: tempSong.duration,
                        songDescription: tempSong.songDescription,
                        kind: tempSong.kind,
                        license: tempSong.license,
                        permalink: tempSong.permalink,
                        permalinkUrl: tempSong.permalinkUrl,
                        permalinkImage: tempSong.permalinkImage,
                        caption: tempSong.caption,
                        downloadUrl: tempSong.downloadUrl,
                        fullDuration: tempSong.fullDuration,
                        likesCount: tempSong.likesCount,
                        playbackCount: tempSong.playbackCount,
                        tagList: tempSong.tagList
                    )
                    return song
                }
                
                // 打印转换后的第一首歌信息用于调试
                if let firstSong = songs.first {
                    logger.debug("""
                    First converted song:
                    - ID: \(firstSong.id)
                    - Title: \(firstSong.title)
                    - Artist: \(firstSong.artist)
                    - Duration: \(firstSong.duration)
                    - PermalinkUrl: \(firstSong.permalinkUrl ?? "N/A")
                    """)
                }
                
                return songs
                
            } catch {
                logger.error("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        logger.error("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        logger.error("Value of type '\(type)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        logger.error("Type '\(type)' mismatch: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        logger.error("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        logger.error("Unknown decoding error: \(error.localizedDescription)")
                    }
                }
                throw NetworkError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
    
    // 获取歌曲详情
    func fetchSongDetails(id: String) async throws -> Song {
        logger.info("Fetching song details for ID: \(id)")
        return try await fetch("/music/\(id)")
    }
    
    // 获取歌曲流派列表
    func fetchGenres() async throws -> [String] {
        logger.info("Fetching music genres")
        return try await fetch("/music/genres")
    }
    
    // 根据流派获取歌曲
    func fetchSongsByGenre(_ genre: String) async throws -> [Song] {
        logger.info("Fetching songs for genre: \(genre)")
        return try await fetch("/music/genres/\(genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
    }
    
    // 获取真实播放地址
    func fetchRealPlayUrl(permalinkUrl: String) async throws -> String {
        logger.info("Fetching real play URL for: \(permalinkUrl)")
        
        guard let url = URL(string: baseURL + "/music/soundcloud/permalink/") else {
            logger.error("Invalid URL for permalink")
            throw NetworkError.invalidURL
        }
        
        // 构建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("yP967q1CrWTf1QLlaTyWdHQOM6SBJSM7dlaOl5CDjKXsUmhwXDTXcTXYVwGqd3hv", forHTTPHeaderField: "X-CSRFTOKEN")
        
        // 构建请求体，使用传入的 permalinkUrl
        let requestBody = ["permalink_url": permalinkUrl]
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            logger.debug("Request body: \(String(data: jsonData, encoding: .utf8) ?? "")")
            logger.debug("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        } catch {
            logger.error("Failed to encode request body: \(error.localizedDescription)")
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 记录响应数据以便调试
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("Response data: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            logger.debug("Response status code: \(httpResponse.statusCode)")
            logger.debug("Response headers: \(httpResponse.allHeaderFields)")
            
            // 如果状态码是500或404，记录更详细的错误信息
            if httpResponse.statusCode >= 400 {
                if let errorString = String(data: data, encoding: .utf8) {
                    logger.error("Server error response: \(errorString)")
                }
                throw NetworkError.serverError("Server Error: \(httpResponse.statusCode)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorString = String(data: data, encoding: .utf8) {
                    logger.error("Error response: \(errorString)")
                }
                logger.error("Invalid response status: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }
            
            struct PlayUrlResponse: Codable {
                let officialUrl: String
                
                enum CodingKeys: String, CodingKey {
                    case officialUrl = "official_url"  // 修改为正确的字段名
                }
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(PlayUrlResponse.self, from: data)
                logger.info("Successfully got real play URL: \(result.officialUrl)")
                return result.officialUrl
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                if let responseString = String(data: data, encoding: .utf8) {
                    logger.error("Failed to decode response: \(responseString)")
                }
                throw NetworkError.decodingError
            }
        } catch {
            logger.error("Network error: \(error)")
            if let networkError = error as? NetworkError {
                throw networkError
            }
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
    
    private func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        logger.info("Fetching data from endpoint: \(endpoint)")
        
        guard let url = URL(string: baseURL + endpoint) else {
            logger.error("Invalid URL: \(baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            logger.debug("Response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("Invalid response status: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                logger.info("Successfully decoded response")
                return result
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                logger.error("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                throw NetworkError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
    
    // 获取音乐类型
    func fetchGenres() async throws -> [Genre] {
        logger.info("Fetching genres")
        let endpoint = "/music/soundcloud/genres/"
        
        guard let url = URL(string: baseURL + endpoint) else {
            logger.error("Invalid URL: \(baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            logger.debug("Response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("Invalid response status: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }
            
            do {
                let decoder = JSONDecoder()
                let genres = try decoder.decode([Genre].self, from: data)
                logger.info("Successfully fetched \(genres.count) genres")
                return genres
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                logger.error("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                throw NetworkError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
    
    // 获取指定类型的歌曲
    func fetchGenreSongs(page: Int = 1, query: String) async throws -> [Song] {
        logger.info("Fetching songs for genre: \(query), page: \(page)")
        
        // 创建URLComponents来正确处理查询参数
        var components = URLComponents(string: baseURL)
        components?.path = "/music/soundcloud/genre/songs/"
        
        // 添加查询参数
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "query", value: query)
        ]
        
        // 获取完整的URL
        guard let url = components?.url else {
            logger.error("Failed to construct URL with components")
            throw NetworkError.invalidURL
        }
        
        logger.debug("Constructed URL: \(url.absoluteString)")
        
        do {
            logger.debug("Making request to: \(url.absoluteString)")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Response is not HTTPURLResponse")
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = "Invalid response status: \(httpResponse.statusCode)"
                logger.error(errorMessage)
                throw NetworkError.serverError(errorMessage)
            }
            
            // 创建临时解码结构
            struct TempSong: Codable {
                let title: String
                let artist: String
                let album: String?
                let genre: String?
                let releaseDate: String?
                let duration: Int
                let songDescription: String?
                let kind: String?
                let license: String?
                let permalink: String?
                let permalinkUrl: String?
                let permalinkImage: String?
                let caption: String?
                let downloadUrl: String?
                let fullDuration: Int?
                let likesCount: Int?
                let playbackCount: Int?
                let tagList: String?
                
                enum CodingKeys: String, CodingKey {
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
            }
            
            do {
                let decoder = JSONDecoder()
                let tempSongs = try decoder.decode([TempSong].self, from: data)
                
                // 将临时歌曲转换为正式的 Song 对象
                let songs = tempSongs.enumerated().map { index, tempSong -> Song in
                    // 基础ID从1000开始
                    // offset 表示已经跳过的数量
                    // index 是当前页中的索引
                    let id = 1000 + page*30 + index
                    
                    let song = Song(
                        id: id,
                        title: tempSong.title,
                        artist: tempSong.artist,
                        album: tempSong.album,
                        genre: tempSong.genre,
                        releaseDate: tempSong.releaseDate,
                        duration: tempSong.duration,
                        songDescription: tempSong.songDescription,
                        kind: tempSong.kind,
                        license: tempSong.license,
                        permalink: tempSong.permalink,
                        permalinkUrl: tempSong.permalinkUrl,
                        permalinkImage: tempSong.permalinkImage,
                        caption: tempSong.caption,
                        downloadUrl: tempSong.downloadUrl,
                        fullDuration: tempSong.fullDuration,
                        likesCount: tempSong.likesCount,
                        playbackCount: tempSong.playbackCount,
                        tagList: tempSong.tagList
                    )
                    return song
                }
                
                logger.info("Successfully decoded \(songs.count) songs")
                return songs
                
            } catch {
                logger.error("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        } catch {
            logger.error("Network error: \(error)")
            throw error
        }
    }
}



