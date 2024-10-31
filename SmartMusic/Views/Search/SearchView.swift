import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SearchViewModel()
    private let logger = LogService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                SearchBar(text: $viewModel.searchText, onSubmit: {
                    viewModel.search()
                })
                .padding()
                
                if !viewModel.searchHistory.isEmpty {
                    HStack {
                        Text(NSLocalizedString("search.history", comment: ""))
                            .font(.headline)
                        Spacer()
                        Button(NSLocalizedString("search.clear", comment: "")) {
                            viewModel.clearHistory()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100))
                    ], spacing: 12) {
                        ForEach(viewModel.searchHistory, id: \.self) { query in
                            Button(action: {
                                viewModel.searchText = query
                                viewModel.search()
                            }) {
                                Text(query)
                                    .lineLimit(1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle(NSLocalizedString("tab.search", comment: ""))
            .sheet(isPresented: $viewModel.showSearchResults) {
                NavigationView {
                    SearchResultsView(
                        songs: viewModel.searchResults,
                        searchQuery: viewModel.searchText,
                        modelContext: modelContext
                    )
                }
            }
            .overlay {
                if viewModel.isSearching {
                    ProgressView()
                }
            }
        }
    }
}
