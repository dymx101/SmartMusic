import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username: String
    private let logger = LogService.shared
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _username = State(initialValue: viewModel.user?.username ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("用户名", text: $username)
                        .onChange(of: username) { newValue in
                            logger.debug("Username input changed: \(newValue)")
                        }
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        logger.info("User cancelled profile editing")
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        logger.info("Saving profile changes")
                        viewModel.updateUsername(username)
                    }
                    .disabled(username.isEmpty)
                }
            }
        }
        .onAppear {
            logger.info("Edit profile view appeared")
        }
    }
}
