import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Song] = []
    @Published var genres: [Genre] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private var searchTask: Task<Void, Never>?
    private let logger = LogService.shared
    
    init() {
        fetchGenres()
    }
    
    func fetchGenres() {
        Task {
            do {
                genres = try await NetworkService.shared.fetchGenres()
                logger.info("Fetched \(genres.count) genres")
            } catch {
                logger.error("Failed to fetch genres: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func search() {
        searchTask?.cancel()
        
        guard !searchText.isEmpty else {
            logger.debug("Search text is empty, clearing results")
            searchResults = []
            return
        }
        
        logger.info("Starting search for: \(searchText)")
        searchTask = Task {
            isSearching = true
            do {
                let results = try await NetworkService.shared.searchSongs(query: searchText)
                if !Task.isCancelled {
                    searchResults = results
                    logger.info("Found \(results.count) results for: \(searchText)")
                }
            } catch {
                logger.error("Search failed: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }
}
