import SwiftUI
import SwiftData
import Foundation

@Model
final class CustomFieldLayout {
    var id: UUID = UUID()
    var name: String
    var fields: [CustomField]
    
    init(name: String, fields: [CustomField]) {
        self.name = name
        self.fields = fields
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
    
    //리뷰 관련 변수
    @State private var selectedReview: Review? = nil // 이동할 리뷰 상태 저장
    @State private var reviewText = ""
    @State private var rating = 1
    @State private var watchDate = Date()
    @State private var watchLocation = ""
    @State private var friends = ""
    
    // 커스텀 필드 관련
    @State private var customFields: [CustomField] = []
    @State private var newFieldName: String = ""
    
    //뷰 이동&모달 여부
    @State private var showReviewField = false // 리뷰 입력창 표시 여부
    @State private var navigateToFullReview = false // FullReviewView로 이동 여부
    
    //커스텀 필드 레이아웃
    @State private var savedLayouts: [CustomFieldLayout] = []
    @State private var selectedLayout: CustomFieldLayout? = nil
    @State private var showSaveLayoutModal = false
    @State private var newLayoutName: String = "" // 새로운 레이아웃 이름
    
    let movie: Movie  // DetailView에서 전달받은 영화 정보
    
    //movie tag 추출용
    private var Tags: String {
        let genreTags = movie.genre.prefix(2).map { "#\($0)" }
        let keywordTag = movie.keyword.prefix(1).map { "#\($0)" }
        return (genreTags + keywordTag).joined(separator: " ")
    }
    
    //커스텀 필드 추가, 삭제
    private func addCustomField() {
        guard !newFieldName.isEmpty else { return }
        customFields.append(CustomField(name: newFieldName, value: ""))
        newFieldName = ""
    }
    
    private func resetCustomFields() {
        customFields.removeAll()
    }
    
    private func saveCurrentLayout(name:String) {
        guard !customFields.isEmpty else { return }
        let layoutName = "\(name)"
        let newLayout = CustomFieldLayout(name: layoutName, fields: customFields)
        savedLayouts.append(newLayout)
        modelContext.insert(newLayout) // SwiftData에 저장
    }
    
    private func deleteLayout(_ layout: CustomFieldLayout) {
        if let index = savedLayouts.firstIndex(where: { $0.id == layout.id }) {
            savedLayouts.remove(at: index)
            modelContext.delete(layout) // SwiftData에서 삭제
        }
    }

    private func loadLayout(_ layout: CustomFieldLayout) {
        customFields = layout.fields.map {
            CustomField(name: $0.name, value: "")
        }
    }
    private func fetchSavedLayouts() {
        do {
            savedLayouts = try modelContext.fetch(FetchDescriptor<CustomFieldLayout>())
        } catch {
            print("Fetch failed: \(error)")
            savedLayouts = []
        }
    }
    private func resetToDefaultLayout() {
        // 커스텀 필드 배열 초기화
        customFields.removeAll()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { geometry in
                    VStack {
                        AsyncImageView(_URL: movie.still)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                            .overlay(Color.white.opacity(0.7))
                            .overlay(
                                VStack(alignment: .center) {
                                    HStack {
                                        AsyncImageView(_URL: movie.poster)
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
                                        Text("출연자:\(String(movie.actor.first ?? "null"))")
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
                            TextField("영화를 같이 본 사람", text: $friends)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // 레이아웃
                        Text("커스텀 정보")
                            .font(.headline)
                            .padding(.top)
                        
                        HStack{
                            Text("레이아웃:")
                                .font(.body)
                            Picker("레이아웃 선택", selection: $selectedLayout) {
                                Text("선택된 레이아웃 없음").tag(nil as CustomFieldLayout?)
                                ForEach(savedLayouts, id: \.id) { layout in
                                    Text(layout.name).tag(layout as CustomFieldLayout?)
                                }
                            }
                            .onChange(of: selectedLayout) { layout in
                                if let layout = layout {
                                    loadLayout(layout)
                                }
                                else {
                                    resetToDefaultLayout() // 선택된 레이아웃 없음 처리
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                .sheet(isPresented: $showSaveLayoutModal) {
                    SaveLayoutModal(isPresented: $showSaveLayoutModal, newLayoutName: $newLayoutName, saveAction: saveCurrentLayout)
                        .presentationDetents([.fraction(0.3)]) // 하단 모달 크기
                }

                   // 커스텀 필드 추가
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
                            TextField("새 항목 이름 입력", text: $newFieldName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("추가") {
                                addCustomField()
                            }
                        }
                        HStack{
                            if !customFields.isEmpty {
                                Button("현재 레이아웃 저장") {
                                    showSaveLayoutModal = true
                                }
                                .padding()
                                .foregroundColor(.blue)
                            }
                            
                            // Delete Layout Button
                            if let selectedLayout = selectedLayout {
                                Button("현재 레이아웃 삭제") {
                                    deleteLayout(selectedLayout)
                                    self.selectedLayout = nil // 선택 초기화
                                }
                                .foregroundColor(.red)
                            }
                        }
                        
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
                        let movieStorage = movie.toStorage()
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
                .onAppear {
                    fetchSavedLayouts()
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToFullReview) {
                if let review = selectedReview {
                    FullReviewView(review: review)
                } else {
                    Text("리뷰가 없음")
                }
            }
            
        }
    }
}

struct SaveLayoutModal: View {
    @Binding var isPresented: Bool
    @Binding var newLayoutName: String
    let saveAction: (String) -> Void
    
    var body: some View {
        VStack {
            Text("새 레이아웃 저장")
                .font(.headline)
            TextField("레이아웃 이름 입력", text: $newLayoutName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("저장") {
                saveAction(newLayoutName)
                isPresented = false
            }
            .padding()
            .background(Color.blue.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(newLayoutName.isEmpty)
        }
        .padding()
    }
}

struct AsyncImageView: View {
    let _URL: String?

    var body: some View {
        if let rURL = _URL, let url = URL(string: rURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                case .failure(let error):
                    // 실패 시 오류 메시지를 화면에 표시
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                        Text("Failed to load image: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "photo")
                .resizable()
        }
    }
}


extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
