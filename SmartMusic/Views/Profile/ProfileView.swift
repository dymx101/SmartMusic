import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ProfileViewModel
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息区
                UserInfoSection(user: viewModel.user)
                
                // 功能区
                Section {
                    NavigationLink(destination: FavoritesView(modelContext: modelContext)) {
                        Label("我的收藏", systemImage: "heart.fill")
                    }
                    
                    NavigationLink(destination: HistoryView(modelContext: modelContext)) {
                        Label("播放历史", systemImage: "clock.fill")
                    }
                }
                
                // 设置区
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("设置", systemImage: "gear")
                    }
                    
                    Button(action: {
                        logger.info("User tapped logout button")
                    }) {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("我的")
            .toolbar {
                Button(action: { viewModel.showEditProfile = true }) {
                    Text("编辑")
                }
            }
            .sheet(isPresented: $viewModel.showEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
        }
        .onAppear {
            logger.info("Profile view appeared")
        }
    }
}
