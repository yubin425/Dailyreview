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
    @State private var watchDate = Date()
    @State private var watchLocation = ""
    @State private var friends = ""


    var body: some View {
        GeometryReader { geometry in
                    VStack {
                        Image("testImage")                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                            .overlay(Color.white.opacity(0.7))
                            .overlay(
                                VStack(alignment:.center){
                                    HStack{ //이미지 + 별점과 텍스트 hstack
                                        Image("testImage")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150)
                                            .padding(.horizontal)
                                        Spacer()
                                        
                                        VStack {
                                            Text("영화 제목\n영화 출연진들의 이름\n영화 줄거리를 요약해서 적으면 좋을 것 같습니다 영화 줄거리를 요약해서 적으면 좋을 것 같습니다")
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                                .padding(.bottom, 5)
                                            
                                                                 
                                            HStack {
                                                ForEach(1...5, id: \.self) { index in
                                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(index <= rating ? .orange : .black)
                                                        .onTapGesture {
                                                            rating = index
                                                        }
                                                }
                                            } //여기까지 별점 Hstack
                                        } //여기까지 별점&텍스트 vstack
                                        .padding(.horizontal)
                                    }//여기까지 포스터가 속한 hstack
                                    
                                    HStack {
                                    
                                        // 날짜 입력란
                                        HStack {
                                            Text("📅")
                                            DatePicker("", selection: $watchDate, displayedComponents: .date)
                                            .datePickerStyle(CompactDatePickerStyle()) // 날짜 선택기 스타일
                                            .labelsHidden() // 라벨 숨기기
                                                        
                                                    }
                                        Spacer()
                                                    
                                        // 위치 입력란
                                        HStack {
                                            Text("📍")
                                            TextField("영화를 본 위치", text: $watchLocation)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .frame(maxWidth: .infinity) // 가로를 꽉 차게
                                        }
                                                   
                                                } //여기까지 hstack
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                           
                                }
                            
                                
                            )
                          

                    }
                }
        .background(Color.white.opacity(0.3))
             .padding(.vertical)
                .frame(height: 300)
        VStack {

            VStack {
                HStack{
                    Text("리뷰 작성")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // 친구 입력란
                    HStack {
                        Text("👥") // 이모티콘 추가
                        TextField("영화를 같이 본 친구", text: $friends)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity) // 가로를 꽉 차게
                    }
                        }
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
                    watchDate = Date()
                    watchLocation = ""
                    friends = ""

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
                    watchDate = Date()
                    watchLocation = ""
                    friends = ""
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
