import SwiftUI
import SwiftData

struct SearchResultsView: View {
    let initialSongs: [Song]
    let searchQuery: String
    @State private var songs: [Song]
    @State private var currentPage = 1
    @State private var isLoadingMore = false
    @State private var hasMorePages = true
    @Environment(\.modelContext) private var modelContext
    @StateObject private var playerViewModel: PlayerViewModel
    @State private var showFullPlayer = false
    private let logger = LogService.shared
    private let pageSize = 20
    
    init(songs: [Song], searchQuery: String, modelContext: ModelContext) {
        self.initialSongs = songs
        self.searchQuery = searchQuery
        _songs = State(initialValue: songs)
        _playerViewModel = StateObject(wrappedValue: PlayerViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(songs) { song in
                    SongListRow(
                        song: song,
                        onPlay: {
                            logger.info("Playing song: \(song.title)")
                            playerViewModel.playSong(song)
                        },
                        modelContext: modelContext
                    )
                    .padding(.horizontal)
                    .onAppear {
                        // 当显示最后一个item时加载更多
                        if song.id == songs.last?.id && !isLoadingMore && hasMorePages {
                            Task {
                                await loadMore()
                            }
                        }
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
            
            // 在主线程更新UI
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
