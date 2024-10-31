import SwiftUI
import SwiftData

struct SearchResultsView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @StateObject private var playerViewModel: PlayerViewModel
    @State private var showFullPlayer = false
    @State private var songs: [Song]
    @State private var currentPage = 1
    @State private var isLoadingMore = false
    @State private var hasMorePages = true
    
    private let searchQuery: String
    private let logger = LogService.shared
    private let pageSize = 20
    
    // MARK: - Initialization
    init(songs: [Song], searchQuery: String, modelContext: ModelContext) {
        self.searchQuery = searchQuery
        _songs = State(initialValue: songs)
        _playerViewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(songs) { song in
                    SongListRow(
                        song: song,
                        onPlay: {
                            playerViewModel.playSong(song, fromQueue: songs)
                            showFullPlayer = true
                        },
                        modelContext: modelContext
                    )
                    .padding(.horizontal)
                    .onAppear {
                        checkAndLoadMore(for: song)
                    }
                }
                
                if isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("搜索结果")
        .fullScreenCover(isPresented: $showFullPlayer) {
            PlayerView(modelContext: modelContext)
        }
    }
    
    // MARK: - Helper Methods
    private func checkAndLoadMore(for song: Song) {
        if song.id == songs.last?.id && !isLoadingMore && hasMorePages {
            Task {
                await loadMore()
            }
        }
    }
    
    private func loadMore() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        do {
            let newSongs = try await NetworkService.shared.searchSongs(
                query: searchQuery,
                limit: pageSize,
                offset: (nextPage - 1) * pageSize
            )
            
            await MainActor.run {
                if !newSongs.isEmpty {
                    songs.append(contentsOf: newSongs)
                    currentPage = nextPage
                    hasMorePages = newSongs.count == pageSize
                } else {
                    hasMorePages = false
                }
                isLoadingMore = false
            }
            
            logger.info("Successfully loaded page \(nextPage) with \(newSongs.count) songs")
        } catch {
            await MainActor.run {
                isLoadingMore = false
            }
            logger.error("Failed to load more songs: \(error)")
        }
    }
} 
