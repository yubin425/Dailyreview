import SwiftUI
import SwiftData

@Model
class CustomField: ObservableObject, Identifiable {
    var id: UUID = UUID()
    var name: String
    var value: String
    
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

@Model
class Review: ObservableObject {
    var id: UUID = UUID()
    var movieTitle: String
    var moviePoster: String  // 영화 포스터 이미지 이름
    var reviewText: String
    var rating: Int
    var watchDate: Date
    var watchLocation: String
    var friends: String
    var customFields: [CustomField] = [] // 사용자 정의 필드들
    
    init(movieTitle: String, moviePoster: String, reviewText: String, rating: Int, watchDate: Date, watchLocation: String, friends: String, customFields: [CustomField]) {
        self.movieTitle = movieTitle
        self.moviePoster = moviePoster
        self.reviewText = reviewText
        self.rating = rating
        self.watchDate = watchDate
        self.watchLocation = watchLocation
        self.friends = friends
        self.customFields = customFields
    }
}

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var movieTitle = ""
    @State private var moviePoster = ""
    @State private var reviewText = ""
    @State private var rating = 1
    @State private var watchDate = Date()
    @State private var watchLocation = ""
    @State private var friends = ""
    
    @State private var customFields: [CustomField] = []
    @State private var newFieldName: String = ""
    private func addCustomField() {
        guard !newFieldName.isEmpty else { return }
        customFields.append(CustomField(name: newFieldName, value: ""))
        newFieldName = ""
    }
    private func resetCustomFields() {
        customFields.removeAll()
    }
    
    @State private var showReviewField = false // 리뷰 입력창 표시 여부
    
    let movie: Movie  // DetailView에서 전달받은 영화 정보
    private var Tags: String {
        let genreTags = movie.genre.prefix(2).map { "#\($0)" }
        let keywordTag = movie.keyword.prefix(1).map { "#\($0)" }
        return (genreTags + keywordTag).joined(separator: " ")
    }

 
    var body: some View {
       //ScrollView {
            GeometryReader { geometry in
                VStack {
                    Image("testImage")
                        .resizable()
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
                                        Text("\(movie.title)")
                                            .font(.title)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .padding(.bottom, 5)
                                        Text("\(String(movie.director.first ?? "null")),\(String(movie.releaseYear ?? "null"))")
                                        Text("\(String(movie.plotText ?? "null"))")
                                            .multilineTextAlignment(.center)
                                        
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
                                    Text("출연자:\(String(movie.director.first ?? "null"))")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    
                                    Spacer()
                                    
                                    Text(Tags)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                } //여기까지 hstack
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                            }
                        )//overlay 끝나는 곳
                }//vstack
            }//geometry
            .background(Color.white.opacity(0.3))
            .padding(.vertical)
            .frame(height: 300)
            VStack {
                    // 기본 필드
                List {
                    Section(header: Text("기본 정보")) {
                        // 날짜 입력란
                        HStack {
                            Text("📅 날짜")
                            DatePicker("", selection: $watchDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                            
                        // 위치 입력란
                        HStack {
                            Text("📍 위치")
                            TextField("영화를 본 위치", text: $watchLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                            
                        // 친구 입력란
                        HStack {
                            Text("👥 같이 본 사람")
                            TextField("영화를 같이 본 친구", text: $friends)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                        
                    // 커스텀 필드
                    Section(header: Text("커스텀 필드")) {
                        ForEach($customFields) { $field in
                            HStack {
                                TextField("필드 이름", text: $field.name)
                                Divider()
                                TextField("값을 입력하세요", text: $field.value)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .onDelete { indexSet in
                            customFields.remove(atOffsets: indexSet)
                            }
                            
                            // 새로운 필드 추가
                        HStack {
                            TextField("새 필드 이름 입력", text: $newFieldName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("추가") {
                                addCustomField()
                            }
                        }
                        // 커스텀 필드 리셋 버튼
                        Button("모든 커스텀 필드 리셋") {
                            resetCustomFields()
                        }
                        .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                
            
                    // +상세 리뷰 추가 버튼
                    Button(action: {
                        withAnimation {
                            showReviewField.toggle() // 버튼을 누르면 표시 여부 토글
                        }
                    }) {
                        Text(showReviewField ? "리뷰 닫기" : "+상세 리뷰 추가")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .sheet(isPresented: $showReviewField) {
                        ReviewTextEditorView(reviewText: $reviewText)// 모달로 표시될 뷰
                    }
            }
            
            
            Spacer()
            
            // Save and Cancel Buttons
            HStack {
                Button("등록") {
                    let newReview = Review(movieTitle: movieTitle, moviePoster: moviePoster, reviewText: reviewText, rating: rating, watchDate: watchDate, watchLocation: watchLocation, friends: friends, customFields: customFields)
                    modelContext.insert(newReview)
                    movieTitle = ""
                    moviePoster = ""
                    reviewText = ""
                    rating = 1
                    watchDate = Date()
                    watchLocation = ""
                    friends = ""
                    customFields = []
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("취소") {
                    movieTitle = ""
                    moviePoster = ""
                    reviewText = ""
                    rating = 1
                    watchDate = Date()
                    watchLocation = ""
                    friends = ""
                    customFields = []
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
            } //hstack 끝나는 곳
            .padding(.horizontal)
       // }//scroll view
    } //리뷰 바디 끝나는 곳
}//리뷰 뷰 끝나는 곳


#Preview {
    let dummyMovie = Movie(
               title: "Dummy Movie Title",
               director: ["John Doe"],
               releaseYear: "2023",
               poster: nil,
               still: nil,
               genre: ["Drama", "Thriller"],
               keyword: ["Suspense", "Mystery"],
               plotText: "A thrilling tale of suspense and mystery."
           )
    ReviewView(movie: dummyMovie)
}
