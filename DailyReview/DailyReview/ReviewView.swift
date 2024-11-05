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
        GeometryReader { geometry in
                    VStack {
                        Image("testImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                            .overlay(Color.white.opacity(0.7))
                            .overlay(
                                HStack{
                                    Image("testImage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150)
                                    .padding(.horizontal)
                                    Spacer()
                                    
                                    VStack {
                                        Text("영화 포스터, 영화 정보(제목, 출연진)\n출력란\n일시,위치,좌석 적는란 추가 필요")
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.bottom, 10)
                                        
                                        HStack {
                                            ForEach(1...5, id: \.self) { index in
                                                Image(systemName: index <= rating ? "star.fill" : "star")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(index <= rating ? .yellow : .black)
                                                    .onTapGesture {
                                                        rating = index
                                                    }
                                            }
                                        } //여기까지 별점 Hstack
                                        .padding(.top, 10) // 텍스트-별점 사이 여백
                                    } //여기까지 별점&텍스트 vstack
                                    .padding(.horizontal)
                                }
                                
                            )
                          

                    }
                }
        .background(Color.white.opacity(0.3))
             .padding(.vertical)
                .frame(height: 300)
        VStack {

            VStack {
                Text("리뷰 작성")
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
