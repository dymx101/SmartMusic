import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    private let logger = LogService.shared
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索歌曲、歌手", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: text) { newValue in
                    logger.debug("Search input changed: \(newValue)")
                }
            
            if !text.isEmpty {
                Button(action: {
                    logger.debug("Clear search text")
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
