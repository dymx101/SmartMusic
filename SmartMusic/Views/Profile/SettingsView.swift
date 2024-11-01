import SwiftUI

struct SettingsView: View {
    @AppStorage("enableBackgroundPlay") private var enableBackgroundPlay = true
    @AppStorage("enableHighQuality") private var enableHighQuality = false
    @AppStorage("enableAutoPlay") private var enableAutoPlay = true
    private let logger = LogService.shared
    
    var body: some View {
        Form {
            Section(header: Text("settings.playback.title".localized)) {
                Toggle("settings.playback.background".localized, isOn: $enableBackgroundPlay)
                    .onChange(of: enableBackgroundPlay) { newValue in
                        logger.info("Background play setting changed to: \(newValue)")
                    }
                Toggle("settings.playback.quality".localized, isOn: $enableHighQuality)
                    .onChange(of: enableHighQuality) { newValue in
                        logger.info("High quality setting changed to: \(newValue)")
                    }
                Toggle("settings.playback.autoplay".localized, isOn: $enableAutoPlay)
                    .onChange(of: enableAutoPlay) { newValue in
                        logger.info("Auto play setting changed to: \(newValue)")
                    }
            }
            
            Section(header: Text("settings.about.title".localized)) {
                HStack {
                    Text("settings.about.version".localized)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink("settings.about.privacy".localized) {
                    Text("settings.about.privacy.content".localized)
                }
                .onTapGesture {
                    logger.debug("User tapped privacy policy")
                }
                
                NavigationLink("settings.about.terms".localized) {
                    Text("settings.about.terms.content".localized)
                }
                .onTapGesture {
                    logger.debug("User tapped user agreement")
                }
            }
        }
        .navigationTitle("settings.title".localized)
        .onAppear {
            logger.info("Settings view appeared")
        }
    }
}
