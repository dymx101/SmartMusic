import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    private let logger = LogService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                    .padding()
                    .onChange(of: viewModel.searchText) { newValue in
                        logger.debug("Search text changed: \(newValue)")
                    }
                
                if viewModel.isSearching {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { song in
                                SearchResultRow(song: song)
                                    .onTapGesture {
                                        logger.info("User selected search result: \(song.title)")
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("搜索")
        }
        .onChange(of: viewModel.searchText) { _ in
            logger.debug("Triggering search")
            viewModel.search()
        }
    }
}
