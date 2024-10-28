import Foundation
import SwiftData

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showEditProfile = false
    
    private let modelContext: ModelContext
    private let logger = LogService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchUser()
    }
    
    func fetchUser() {
        logger.info("Fetching user profile")
        isLoading = true
        
        let descriptor = FetchDescriptor<User>()
        if let existingUser = try? modelContext.fetch(descriptor).first {
            user = existingUser
            logger.info("Found existing user: \(existingUser.username)")
        } else {
            logger.info("No existing user found, creating default user")
            let defaultUser = User(username: "音乐爱好者")
            modelContext.insert(defaultUser)
            try? modelContext.save()
            user = defaultUser
        }
        
        isLoading = false
    }
    
    func updateUsername(_ newName: String) {
        guard !newName.isEmpty else {
            logger.warning("Attempted to update username with empty string")
            return
        }
        
        logger.info("Updating username from '\(user?.username ?? "")' to '\(newName)'")
        user?.username = newName
        
        do {
            try modelContext.save()
            logger.info("Successfully updated username")
        } catch {
            logger.error("Failed to update username: \(error.localizedDescription)")
        }
        
        showEditProfile = false
    }
    
    func updateAvatar(_ newAvatar: String) {
        logger.info("Updating user avatar")
        user?.avatar = newAvatar
        
        do {
            try modelContext.save()
            logger.info("Successfully updated avatar")
        } catch {
            logger.error("Failed to update avatar: \(error.localizedDescription)")
        }
    }
}
