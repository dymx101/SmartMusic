import SwiftUI

struct UserInfoSection: View {
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
            Text(user?.username ?? "未登录")
                .font(.title2)
                .bold()
            
            // 统计信息
            HStack(spacing: 40) {
                VStack {
                    Text("\(user?.favoriteCount ?? 0)")
                        .font(.headline)
                    Text("收藏")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(user?.playlistCount ?? 0)")
                        .font(.headline)
                    Text("歌单")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(user?.historyCount ?? 0)")
                        .font(.headline)
                    Text("历史")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
}
