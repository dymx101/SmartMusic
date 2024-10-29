import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SearchViewModel()
    private let logger = LogService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                    .padding()
                
                if viewModel.isSearching {
                    ProgressView()
                } else {
                    searchResultsSection
                }
            }
            .navigationTitle("搜索")
        }
    }
    
    private var searchResultsSection: some View {
        List(viewModel.searchResults) { song in
            SearchResultRow(song: song)
        }
    }
}
