import Foundation
import SwiftUI

@MainActor
class GenreSongsViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var isLoading = false
    @Published var currentPage = 1
    @Published var hasMorePages = true
    @Published var isGridView = false
    @Published var errorMessage: String?
    
    private let genreTitle: String
    private let logger = LogService.shared
    private var lastUsedId = 0
    
    init(genreTitle: String) {
        self.genreTitle = genreTitle
        logger.info("Initializing GenreSongsViewModel with genre: \(genreTitle)")
    }
    
    private func generateUniqueIds(for songs: [Song]) -> [Song] {
        return songs.map { song in
            var modifiedSong = song
            lastUsedId += 1
            modifiedSong.id = lastUsedId
            return modifiedSong
        }
    }
    
    func fetchSongs(forceRefresh: Bool = false) async {
        guard !isLoading && (hasMorePages || forceRefresh) else { return }
        
        isLoading = true
        logger.info("Fetching songs for genre: \(genreTitle), page: \(currentPage), forceRefresh: \(forceRefresh)")
        
        if forceRefresh {
            currentPage = 1
            songs = []
            lastUsedId = 0
        }
        
        do {
            var newSongs = try await NetworkService.shared.fetchGenreSongs(
                page: currentPage,
                query: genreTitle
            )
            
            newSongs = generateUniqueIds(for: newSongs)
            
            if currentPage == 1 {
                songs = newSongs
            } else {
                songs.append(contentsOf: newSongs)
            }
            
            hasMorePages = !newSongs.isEmpty
            if hasMorePages {
                currentPage += 1
            }
            
            logger.info("Successfully fetched \(newSongs.count) songs. Total songs: \(songs.count), Next page: \(currentPage)")
            errorMessage = nil
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                errorMessage = "无效的URL"
                logger.error("Invalid URL error for genre: \(genreTitle)")
            case .invalidResponse:
                errorMessage = "服务器响应无效"
                logger.error("Invalid response error for genre: \(genreTitle)")
            case .decodingError:
                errorMessage = "数据解析错误"
                logger.error("Decoding error for genre: \(genreTitle)")
            case .serverError(let message):
                errorMessage = "服务器错误: \(message)"
                logger.error("Server error for genre: \(genreTitle) - \(message)")
            }
        } else {
            errorMessage = "未知错误: \(error.localizedDescription)"
            logger.error("Unknown error for genre: \(genreTitle) - \(error)")
        }
    }
    
    func toggleViewMode() {
        isGridView.toggle()
        logger.debug("View mode toggled to: \(isGridView ? "grid" : "list")")
    }
} 