import Foundation

class AppConfigManager {
    static let shared = AppConfigManager()
    private let logger = LogService.shared
    
    struct RemoteConfig: Codable {
        let serverIp: [String]
        let featureFlags: FeatureFlags
        
        struct FeatureFlags: Codable {
            let musicApp: MusicApp
            
            struct MusicApp: Codable {
                let fullAccess: FullAccess
                
                struct FullAccess: Codable {
                    let platforms: Platforms
                    
                    struct Platforms: Codable {
                        let ios: Platform
                        let android: Platform
                        
                        struct Platform: Codable {
                            let minVersion: Int
                            let enabled: Bool
                        }
                    }
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case musicApp = "musicApp"
            }
        }
    }
    
    @Published private(set) var config: RemoteConfig?
    @Published private(set) var activeServerIp: String?
    private let configUrl = "https://dymx102.github.io/PhotoMagicSite/configs/app_config.json"
    
    private init() {
        Task {
            await fetchConfig()
        }
    }
    
    func fetchConfig() async {
        guard let url = URL(string: configUrl) else {
            logger.error("Invalid config URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            config = try decoder.decode(RemoteConfig.self, from: data)
            logger.info("Successfully fetched remote config")
            
            // After fetching config, check server IPs
            if let serverIps = config?.serverIp {
                await findAccessibleServer(from: serverIps)
            }
        } catch {
            logger.error("Failed to fetch remote config: \(error.localizedDescription)")
        }
    }
    
    private func findAccessibleServer(from serverIps: [String]) async {
        logger.info("Checking accessibility of \(serverIps.count) servers")
        
        for serverIp in serverIps {
            let testUrl = "http://\(serverIp):8000"  // Test the base URL directly
            
            guard let url = URL(string: testUrl) else { continue }
            
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    // Any response (even error responses) means the server is reachable
                    logger.info("Found accessible server: \(serverIp) with status code: \(httpResponse.statusCode)")
                    activeServerIp = serverIp
                    return
                }
            } catch {
                logger.debug("Server \(serverIp) is not accessible: \(error.localizedDescription)")
                continue
            }
        }
        
        // If no server is accessible, use the first one as fallback
        if activeServerIp == nil {
            activeServerIp = serverIps.first
            logger.warning("No accessible server found, using first server as fallback: \(activeServerIp ?? "none")")
        }
    }
    
    var apiBaseUrl: String {
        if let activeServer = activeServerIp {
            return "http://\(activeServer):8000"
        }
        // Fallback to first server in config, or default if none available
        if let serverIps = config?.serverIp, !serverIps.isEmpty {
            return "http://\(serverIps[0]):8000"
        }
        return "http://35.188.0.156:8000"
    }
    
    var isFullAccessEnabled: Bool {
        config?.featureFlags.musicApp.fullAccess.platforms.ios.enabled ?? false
    }
    
    var minimumRequiredVersion: Int {
        config?.featureFlags.musicApp.fullAccess.platforms.ios.minVersion ?? 1
    }
    
    var shouldEnableFullAccess: Bool {
        guard let config = config else {
            logger.warning("Config not available, defaulting shouldEnableFullAccess to true")
            return true
        }
        
        // Get current build number
        guard let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
              let currentBuildNumber = Int(buildNumber) else {
            logger.error("Could not get build number, defaulting shouldEnableFullAccess to true")
            return true
        }
        
        let minVersion = config.featureFlags.musicApp.fullAccess.platforms.ios.minVersion
        let isEnabled = config.featureFlags.musicApp.fullAccess.platforms.ios.enabled
        
        logger.debug("Checking full access - Build: \(currentBuildNumber), Min: \(minVersion), Enabled: \(isEnabled)")
        
        if currentBuildNumber >= minVersion {
            // For newer versions, respect the enabled flag
            return isEnabled
        } else {
            // For older versions, always enable full access
            logger.info("App version (\(currentBuildNumber)) is below minimum (\(minVersion)), enabling full access")
            return true
        }
    }
} 
