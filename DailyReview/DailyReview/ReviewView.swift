import SwiftUI
import SwiftData

@Model
class Review {
    var id: UUID = UUID() // 고유 id 생성 기능
    var movieTitle: String
    var reviewText: String
    var rating: Int
    
    init(movieTitle: String, reviewText: String, rating: Int) {
        self.movieTitle = movieTitle
        self.reviewText = reviewText
        self.rating = rating
    }
}

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var movieTitle = ""
    @State private var reviewText = ""
    @State private var rating = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘의 영화는?")
                .font(.title)

            TextField("Movie Title", text: $movieTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Review", text: $reviewText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Rating:")
                .font(.headline)

            HStack {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            
            Button("Save Review") {
                let newReview = Review(movieTitle: movieTitle, reviewText: reviewText, rating: rating)
                modelContext.insert(newReview)
                
                // 초기화
                movieTitle = ""
                reviewText = ""
                rating = 1
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    ReviewView()
}
