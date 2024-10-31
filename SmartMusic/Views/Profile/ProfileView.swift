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
                        Label(NSLocalizedString("profile.favorites", comment: ""), systemImage: "heart.fill")
                    }
                    
                    NavigationLink(destination: HistoryView(modelContext: modelContext)) {
                        Label(NSLocalizedString("profile.history", comment: ""), systemImage: "clock.fill")
                    }
                }
                
                // 设置区
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label(NSLocalizedString("profile.settings", comment: ""), systemImage: "gear")
                    }
                    
                    Button(action: {
                        logger.info("User tapped logout button")
                    }) {
                        Label(NSLocalizedString("profile.logout", comment: ""), systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tab.profile", comment: ""))
            .toolbar {
                Button(action: { viewModel.showEditProfile = true }) {
                    Text(NSLocalizedString("profile.edit", comment: ""))
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
