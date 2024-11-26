import SwiftUI
import SwiftData
import Foundation


@Model
class MovieStorage: ObservableObject, Identifiable {
    var id: UUID
    var title: String
    var director: [String]
    var releaseYear: String?
    var poster: String?
    var still: String?
    var genre: [String]
    var keyword: [String]
    var plotText: String?
    
    
    init(id: UUID, title: String, director: [String], releaseYear: String? = nil, poster: String? = nil, still: String? = nil, genre: [String], keyword: [String], plotText: String? = nil) {
        self.id = id
        self.title = Movie.cleanStr(from: title)
        self.director = director.map { Movie.cleanStr(from: $0) }
        self.releaseYear = releaseYear
        self.poster = Movie.extractFirst(from: poster)?.replacingOccurrences(of: "http://", with: "https://")
        self.still = Movie.extractFirst(from: still)?.replacingOccurrences(of: "http://", with: "https://")
        self.genre = genre
        self.keyword = keyword
        self.plotText = plotText
    }
}




@Model
class CustomField: ObservableObject, Identifiable {
    var id: UUID
    var name: String
    var value: String
    @Relationship(inverse: \Review.customFields) var review: Review?
    init(name: String, value: String) {
        self.name = name
        self.value = value
        self.id = UUID() // Ensure unique ID
    }
}

@Model
class Review: ObservableObject {
    var id: UUID = UUID()
    @Relationship var movieStorage: MovieStorage //movie 대신 storage로 새로 저장하기
    var reviewText: String
    var rating: Int
    var watchDate: Date
    var watchLocation: String
    var friends: String
    @Relationship var customFields: [CustomField]? // 사용자 정의 필드들
    
    init(movieStorage: MovieStorage, reviewText: String, rating: Int, watchDate: Date, watchLocation: String, friends: String) {
        self.movieStorage = movieStorage
        self.reviewText = reviewText
        self.rating = rating
        self.watchDate = watchDate
        self.watchLocation = watchLocation
        self.friends = friends
    }
}

struct ReviewView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // 이전 화면으로 복귀를 위한 dismiss 환경 변수
    
    @State private var selectedReview: Review? = nil // 이동할 리뷰 상태 저장
    @State private var reviewText = ""
    @State private var rating = 1
    @State private var watchDate = Date()
    @State private var watchLocation = ""
    @State private var friends = ""
    
    // 커스텀 필드 관련
    @State private var customFields: [CustomField] = []
    @State private var newFieldName: String = ""
    
    @State private var isEditing = false // 편집 모드 활성화 여부
    @State private var editingField: CustomField? = nil // 수정할 필드
    
    @State private var showReviewField = false // 리뷰 입력창 표시 여부
    @State private var navigateToFullReview = false // FullReviewView로 이동 여부
    
    let movie: Movie  // DetailView에서 전달받은 영화 정보
    private var Tags: String {
        let genreTags = movie.genre.prefix(2).map { "#\($0)" }
        let keywordTag = movie.keyword.prefix(1).map { "#\($0)" }
        return (genreTags + keywordTag).joined(separator: " ")
    }
    
    private func addCustomField() {
        guard !newFieldName.isEmpty else { return }
        customFields.append(CustomField(name: newFieldName, value: ""))
        newFieldName = ""
    }
    
    private func resetCustomFields() {
        customFields.removeAll()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { geometry in
                    VStack {
                        Image("testImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                            .overlay(Color.white.opacity(0.7))
                            .overlay(
                                VStack(alignment: .center) {
                                    HStack {
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
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    HStack {
                                        Text("출연자:\(String(movie.director.first ?? "null"))")
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        
                                        Spacer()
                                        
                                        Text(Tags)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
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
                    VStack(alignment: .leading) {
                        Text("기본 정보")
                            .font(.headline)
                            .padding(.top)
                        
                        HStack {
                            Text("📅 날짜")
                            Divider()
                            DatePicker("", selection: $watchDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("📍 위치")
                            Divider()
                            TextField("영화를 본 위치", text: $watchLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("👥 사람")
                            Divider()
                            TextField("영화를 같이 본 친구", text: $friends)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        ForEach($customFields) { $field in
                            HStack {
                                TextField("필드 이름", text: $field.name)
                                Divider()
                                TextField("값을 입력하세요", text: $field.value)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    if let index = customFields.firstIndex(where: { $0.id == field.id }) {
                                        customFields.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                }
                                .padding(.leading, 8)
                            }
                        }
                        
                        HStack {
                            TextField("새 필드 이름 입력", text: $newFieldName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("추가") {
                                addCustomField()
                            }
                        }
                        
                        Button("모든 커스텀 필드 리셋") {
                            resetCustomFields()
                        }
                        .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showReviewField.toggle()
                        }
                    }) {
                        Text(showReviewField ? "리뷰 닫기" : "+상세 리뷰 추가")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .sheet(isPresented: $showReviewField) {
                        ReviewTextEditorView(reviewText: $reviewText)
                            .presentationDragIndicator(.visible)
                    }
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Button("등록") {
                        // 영화 정보 저장
                        let movieStorage = MovieStorage(
                            id: movie.id,
                            title: movie.title,
                            director: movie.director,
                            releaseYear: movie.releaseYear,
                            poster: movie.poster,
                            still: movie.still,
                            genre: movie.genre,
                            keyword: movie.keyword,
                            plotText: movie.plotText
                        )
                        modelContext.insert(movieStorage) // SwiftData 컨텍스트에 삽입

                        // 리뷰 생성
                        let newReview = Review(
                            movieStorage: movieStorage,
                            reviewText: reviewText,
                            rating: rating,
                            watchDate: watchDate,
                            watchLocation: watchLocation,
                            friends: friends
                        )
                        modelContext.insert(newReview) // SwiftData 컨텍스트에 삽입

                        // 커스텀 필드 추가 및 관계 설정
                        for field in customFields {
                            field.review = newReview
                            modelContext.insert(field) // SwiftData 컨텍스트에 삽입
                        }

                        // 상태 업데이트 및 이동
                        selectedReview = newReview
                        navigateToFullReview = true // Navigation trigger
                    }

                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("취소") {
                        reviewText = ""
                        rating = 1
                        watchDate = Date()
                        watchLocation = ""
                        friends = ""
                        customFields = []
                        dismiss() // 이전 화면으로 복귀
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToFullReview) {
                if let review = selectedReview {
                    FullReviewView(review: review)
                } else {
                    Text("No Review Found")
                }
            }
            
        }
    }
}


//
//#Preview {
//    let dummyMovie = Movie(
//        title: "Dummy Movie Title",
//        director: ["John Doe"],
//        releaseYear: "2023",
//        poster: nil,
//        still: nil,
//        genre: ["Drama", "Thriller"],
//        keyword: ["Suspense", "Mystery"],
//        plotText: "A thrilling tale of suspense and mystery."
//    )
//    
//    // 샘플 데이터를 위한 SwiftData 컨테이너 설정
//    let container = try! ModelContainer(for: Review.self, CustomField.self, MovieStorage.self)
//
//    ReviewView(movie: dummyMovie)
//        .modelContainer(container)
//}
