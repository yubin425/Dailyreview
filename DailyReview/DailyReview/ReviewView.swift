import SwiftUI
import SwiftData

@Model
class Review {
    var id: UUID = UUID()
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
        VStack {
            // Placeholder for movie poster and info with rating stars
            VStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Text("영화 포스터, 영화 정보(제목, 출연진)\n출력란")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
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
                            .padding(.top, 10) // Add some spacing between text and stars
                        }
                    )
            }
            .padding(.horizontal)
            
            // Review TextField Area
            VStack {
                Text("리뷰 작성하기")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $reviewText)
                    .frame(height: 300)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.bottom, 20)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Save and Cancel Buttons
            HStack {
                Button("등록") {
                    let newReview = Review(movieTitle: movieTitle, reviewText: reviewText, rating: rating)
                    modelContext.insert(newReview)
                    movieTitle = ""
                    reviewText = ""
                    rating = 1
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("취소") {
                    movieTitle = ""
                    reviewText = ""
                    rating = 1
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ReviewView()
}
