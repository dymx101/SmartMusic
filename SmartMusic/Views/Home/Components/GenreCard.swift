import SwiftUI

struct GenreCard: View {
    let genre: Genre
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: genre.imageLargeLight)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(genre.title)
                .font(.caption)
                .lineLimit(1)
        }
    }
} 