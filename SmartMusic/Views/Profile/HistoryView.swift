import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: HistoryViewModel
    @StateObject private var playerViewModel = PlayerViewModel()
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.history) { history in
                HistorySongRow(
                    history: history,
                    onPlay: {
                        logger.info("Playing song from history: \(history.song.title)")
                        playerViewModel.playSong(history.song)
                    }
                )
            }
        }
        .navigationTitle("播放历史")
        .toolbar {
            if !viewModel.history.isEmpty {
                Button("清空") {
                    logger.info("User requested to clear play history")
                    viewModel.clearHistory()
                }
            }
        }
        .overlay {
            if viewModel.history.isEmpty {
                ContentUnavailableView(
                    "暂无播放历史",
                    systemImage: "clock.badge.xmark",
                    description: Text("你还没有播放过任何歌曲")
                )
            }
        }
        .onAppear {
            logger.info("History view appeared")
        }
    }
}
