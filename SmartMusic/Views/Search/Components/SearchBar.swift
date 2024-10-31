import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void
    private let logger = LogService.shared
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(NSLocalizedString("search.placeholder", comment: ""), text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    onSubmit()
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
