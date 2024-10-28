import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ProfileViewModel
    
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
                    NavigationLink(destination: FavoritesView()) {
                        Label("我的收藏", systemImage: "heart.fill")
                    }
                    
                    NavigationLink(destination: HistoryView()) {
                        Label("播放历史", systemImage: "clock.fill")
                    }
                }
                
                // 设置区
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("设置", systemImage: "gear")
                    }
                    
                    Button(action: {}) {
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
    }
}
