import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    private let logger = LogService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !viewModel.featuredSongs.isEmpty {
                        FeaturedSongsCarousel(songs: viewModel.featuredSongs)
                            .frame(height: 200)
                            .onAppear {
                                logger.debug("Featured songs carousel appeared")
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("推荐歌曲")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 15) {
                                ForEach(viewModel.recommendedSongs) { song in
                                    SongCard(song: song)
                                        .onTapGesture {
                                            logger.info("User tapped recommended song: \(song.title)")
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("SmartMusic")
            .refreshable {
                logger.info("User triggered refresh")
                await viewModel.fetchRecommendedSongs()
                await viewModel.fetchFeaturedSongs()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
        .task {
            logger.info("HomeView appeared, fetching initial data")
            await viewModel.fetchRecommendedSongs()
            await viewModel.fetchFeaturedSongs()
        }
    }
}
