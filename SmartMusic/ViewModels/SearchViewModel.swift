import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Song] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var searchHistory: [String] = []
    @Published var showSearchResults = false
    
    private let logger = LogService.shared
    private let historyKey = "searchHistory"
    
    init() {
        loadSearchHistory()
    }
    
    func search() {
        guard !searchText.isEmpty else { return }
        
        Task {
            isSearching = true
            do {
                searchResults = try await NetworkService.shared.searchSongs(query: searchText)
                addToHistory(searchText)
                showSearchResults = true
                logger.info("Found \(searchResults.count) results for: \(searchText)")
            } catch {
                logger.error("Search failed: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }
    
    private func addToHistory(_ query: String) {
        if !searchHistory.contains(query) {
            searchHistory.insert(query, at: 0)
            if searchHistory.count > 12 {
                searchHistory.removeLast()
            }
            saveSearchHistory()
        }
    }
    
    func clearHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }
    
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: historyKey)
    }
    
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }
}
