import Foundation
import SwiftUI

class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    enum Language: String, CaseIterable {
        case system = "system"
        case english = "en"
        case chinese = "zh-Hans"
        case japanese = "ja"
        case korean = "ko"
        case french = "fr"
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .english: return "English"
            case .chinese: return "简体中文"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            case .french: return "Français"
            }
        }
    }
    
    @Published var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        }
    }
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "system"
        self.language = Language(rawValue: savedLanguage) ?? .system
    }
    
    func setLanguage(_ language: Language) {
        self.language = language
    }
}

// String extension for localization
extension String {
    var localized: String {
        let language = LocalizationService.shared.language
        guard language != .system else {
            return NSLocalizedString(self, comment: "")
        }
        
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
} 