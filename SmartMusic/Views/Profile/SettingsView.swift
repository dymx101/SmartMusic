import SwiftUI

struct SettingsView: View {
    @AppStorage("enableBackgroundPlay") private var enableBackgroundPlay = true
    @AppStorage("enableHighQuality") private var enableHighQuality = false
    @AppStorage("enableAutoPlay") private var enableAutoPlay = true
    private let logger = LogService.shared
    
    var body: some View {
        Form {
            Section(header: Text("播放设置")) {
                Toggle("后台播放", isOn: $enableBackgroundPlay)
                    .onChange(of: enableBackgroundPlay) { newValue in
                        logger.info("Background play setting changed to: \(newValue)")
                    }
                Toggle("高音质", isOn: $enableHighQuality)
                    .onChange(of: enableHighQuality) { newValue in
                        logger.info("High quality setting changed to: \(newValue)")
                    }
                Toggle("自动播放", isOn: $enableAutoPlay)
                    .onChange(of: enableAutoPlay) { newValue in
                        logger.info("Auto play setting changed to: \(newValue)")
                    }
            }
            
            Section(header: Text("关于")) {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink("隐私政策") {
                    Text("隐私政策内容")
                }
                .onTapGesture {
                    logger.debug("User tapped privacy policy")
                }
                
                NavigationLink("用户协议") {
                    Text("用户协议内容")
                }
                .onTapGesture {
                    logger.debug("User tapped user agreement")
                }
            }
        }
        .navigationTitle("设置")
        .onAppear {
            logger.info("Settings view appeared")
        }
    }
}
