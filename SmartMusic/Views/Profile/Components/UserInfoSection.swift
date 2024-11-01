import SwiftUI
import SwiftData

struct UserInfoSection: View {
    @Environment(\.modelContext) private var modelContext
    let user: User?
    private let logger = LogService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // 头像
            if let avatarURL = user?.avatar {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .onAppear {
                    logger.debug("Loading avatar from URL: \(avatarURL)")
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            // 用户名
            Text(user?.username ?? NSLocalizedString("profile.logout", comment: ""))
                .font(.title2)
                .bold()
            
//            "profile.favorites" = "My Favorites";
//            "profile.history" = "Play History";
//            "profile.settings" = "Settings";
//            "profile.about" = "About";
//            "profile.edit" = "Edit";
//            "profile.logout" = "Logout";
            
            // 统计信息
            HStack(spacing: 40) {
                VStack {
                    Text("\(user?.favoriteCount ?? 0)")
                        .font(.headline)
                    Text(NSLocalizedString("profile.favorites", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(user?.playlistCount ?? 0)")
                        .font(.headline)
                    Text(NSLocalizedString("profile.playlists", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(user?.historyCount ?? 0)")
                        .font(.headline)
                    Text(NSLocalizedString("profile.history", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                updateUserStats()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .listRowInsets(EdgeInsets())
        .onAppear {
            logger.info("User info section appeared for user: \(user?.username ?? "unknown")")
        }
    }
    
    // 添加更新统计信息的方法
    private func updateUserStats() {
        guard let user = user else { return }
        
        // 获取收藏数
        let favoritesDescriptor = FetchDescriptor<Favorite>()
        let favoriteCount = (try? modelContext.fetch(favoritesDescriptor))?.count ?? 0
        
        // 获取播放列表数
        let playlistsDescriptor = FetchDescriptor<Playlist>()
        let playlistCount = (try? modelContext.fetch(playlistsDescriptor))?.count ?? 0
        
        // 获取播放历史数
        let historyDescriptor = FetchDescriptor<PlayHistory>()
        let historyCount = (try? modelContext.fetch(historyDescriptor))?.count ?? 0
        
        // 更新用户统计信息
        user.favoriteCount = favoriteCount
        user.playlistCount = playlistCount
        user.historyCount = historyCount
        
        // 保存更新
        try? modelContext.save()
        
        logger.debug("""
            Updated user stats:
            - Favorites: \(favoriteCount)
            - Playlists: \(playlistCount)
            - History: \(historyCount)
            """)
    }
}
