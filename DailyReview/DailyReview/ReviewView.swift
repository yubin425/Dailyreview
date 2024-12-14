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
    @Environment(\.dismiss) private var dismiss

    // 리뷰 관련 변수
    @State private var selectedReview: Review? = nil
    @State private var reviewText = ""
    @State private var rating = 1
    @State private var watchDate = Date()
    @State private var watchLocation = ""
    @State private var friends = ""

    // 커스텀 필드 관련
    @State private var customFields: [CustomField] = []
    @State private var newFieldName: String = ""

    // 뷰 이동&모달 여부
    @State private var showReviewField = false
    @State private var navigateToFullReview = false

    // 커스텀 필드 레이아웃
    @State private var savedLayouts: [CustomFieldLayout] = []
    @State private var selectedLayout: CustomFieldLayout? = nil
    @State private var showSaveLayoutModal = false
    @State private var newLayoutName: String = ""

    let movie: Movie

    private var Tags: String {
        let genreTags = movie.genre.prefix(2).map { "#\($0)" }
        let keywordTag = movie.keyword.prefix(1).map { "#\($0)" }
        return (genreTags + keywordTag).joined(separator: " ")
    }

    var body: some View {
        NavigationStack {
            VStack{
            ScrollView {
                movieHeaderView()

                VStack {
                    reviewDetailsForm()
                    
                    Divider()

                    customFieldsSection()
                    
                    Divider()

                    reviewTextEditor()
                    
                    Divider()

                    Spacer()

                }
                .padding(.vertical)
            }
            .onAppear {
                fetchSavedLayouts()
            }
                actionButtons()
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

// MARK: - Subviews

extension ReviewView {
    @ViewBuilder
    private func movieHeaderView() -> some View {
        GeometryReader { geometry in
            VStack {
                AsyncImageView(_URL: movie.still)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 270)
                    .clipped()
                    .overlay(Color.white.opacity(0.7))
                    .overlay(movieHeaderOverlay())
            }
        }
        .background(Color.white.opacity(0.3))
        .padding(.vertical)
        .frame(height: 300)
    }

    private func movieHeaderOverlay() -> some View {
        VStack(alignment: .center) {
            HStack {
                AsyncImageView(_URL: movie.poster)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .padding(.horizontal)

                Spacer()

                VStack {
                    Text(movie.title.splitWord())
                        .font(.title)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 5)

                    Text("\(movie.director.first ?? "null"), \(movie.releaseYear ?? "null")")

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
                Text("출연자: \(movie.actor.first ?? "null")")
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
    }

    @ViewBuilder
    private func reviewDetailsForm() -> some View {
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
                    .textFieldStyle(PlainTextFieldStyle())
            }

            HStack {
                Text("👥 사람")
                Divider()
                TextField("영화를 같이 본 사람", text: $friends)
                    .textFieldStyle(PlainTextFieldStyle())
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func customFieldsSection() -> some View {
        VStack(alignment: .leading) {
            Text("커스텀 정보")
                .font(.headline)
                .padding(.top)

            HStack {
                Text("레이아웃:")
                    .font(.body)
                Picker("레이아웃 선택", selection: $selectedLayout) {
                    Text("선택된 레이아웃 없음").tag(nil as CustomFieldLayout?)
                    ForEach(savedLayouts, id: \.id) { layout in
                        Text(layout.name).tag(layout as CustomFieldLayout?)
                    }
                }
                .foregroundColor(.red)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedLayout) { layout in
                    if let layout = layout {
                        loadLayout(layout)
                    } else {
                        resetToDefaultLayout()
                    }
                }
            }

            ForEach($customFields) { $field in
                HStack {
                    TextField("필드 이름", text: $field.name)
                    Divider()
                    TextField("값을 입력하세요", text: $field.value)
                        .textFieldStyle(PlainTextFieldStyle())

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
                .foregroundColor(.red)
            }
            .padding(.top)


            HStack {
                if !customFields.isEmpty {
                    Button("현재 레이아웃 저장") {
                        showSaveLayoutModal = true
                    }
                    .foregroundColor(.red)
                }

                if let selectedLayout = selectedLayout {
                    Button("현재 레이아웃 삭제") {
                        deleteLayout(selectedLayout)
                        self.selectedLayout = nil
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .sheet(isPresented: $showSaveLayoutModal) {
            SaveLayoutModal(isPresented: $showSaveLayoutModal, newLayoutName: $newLayoutName, saveAction: saveCurrentLayout)
                .presentationDetents([.fraction(0.3)])
        }
    }

    @ViewBuilder
    private func reviewTextEditor() -> some View {
        VStack(alignment: .leading) {
            Text("리뷰/메모")
                .font(.headline)
                .padding(.top)
                .padding(.horizontal)
            
            TextEditor(text: $reviewText)
                .padding(.horizontal)
                .frame(minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear // 배경색 제거
                }
                .overlay(
                    // TextEditor가 비어있을 때 placeholder 텍스트 표시
                    Group {
                        if reviewText.isEmpty {
                            Text("상세한 리뷰 내용을 자유롭게 입력하세요")
                                .foregroundColor(.gray)
                                .padding(.top, 10) // 텍스트 위치 조정
                                .padding(.leading, 19)
                        }
                    }
                    , alignment: .topLeading
                )
        }
        .animation(.easeInOut, value: showReviewField)
        .padding(.vertical)
    }

    @ViewBuilder
    private func actionButtons() -> some View {
        HStack {
            Button("등록") {
                let movieStorage = movie.toStorage()
                modelContext.insert(movieStorage)

                let newReview = Review(
                    movieStorage: movieStorage,
                    reviewText: reviewText,
                    rating: rating,
                    watchDate: watchDate,
                    watchLocation: watchLocation,
                    friends: friends
                )
                modelContext.insert(newReview)

                for field in customFields {
                    field.review = newReview
                    modelContext.insert(field)
                }

                selectedReview = newReview
                navigateToFullReview = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("취소") {
                resetForm()
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    private func resetForm() {
        reviewText = ""
        rating = 1
        watchDate = Date()
        watchLocation = ""
        friends = ""
        customFields = []
    }
}

// MARK: - Helper Methods

extension ReviewView {
    private func addCustomField() {
        guard !newFieldName.isEmpty else { return }
        customFields.append(CustomField(name: newFieldName, value: ""))
        newFieldName = ""
    }
    
    private func resetCustomFields() {
        customFields.removeAll()
    }
    
    private func saveCurrentLayout(name: String) {
        guard !customFields.isEmpty else { return }
        let layoutName = name
        let newLayout = CustomFieldLayout(name: layoutName, fields: customFields)
        savedLayouts.append(newLayout)
        modelContext.insert(newLayout)
    }
    
    private func deleteLayout(_ layout: CustomFieldLayout) {
        if let index = savedLayouts.firstIndex(where: { $0.id == layout.id }) {
            savedLayouts.remove(at: index)
            modelContext.delete(layout)
        }
    }
    
    private func loadLayout(_ layout: CustomFieldLayout) {
        customFields = layout.fields.map {
            CustomField(name: $0.name, value: "")
        }
    }
    
    private func resetToDefaultLayout() {
        // 커스텀 필드 배열 초기화
        customFields.removeAll()
    }
    
    private func fetchSavedLayouts() {
        do {
            savedLayouts = try modelContext.fetch(FetchDescriptor<CustomFieldLayout>())
        } catch {
            print("Fetch failed: \(error)")
            
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
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
            Button("저장") {
                saveAction(newLayoutName)
                isPresented = false
            }
            .padding()
            .background(Color.red.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(newLayoutName.isEmpty)
        }
        .padding()
    }
}

//MARK: -AsyncImageView(이미지 처리)
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
                        .scaledToFit()
                case .failure:
                    CustomPlaceholderView()
                @unknown default:
                    EmptyView()
                }
            }
        } else {
           Image(systemName: "photo")
            .resizable()
//            CustomPlaceholderView()
        }
    }
}

struct CustomPlaceholderView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.red, .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text("""
                 Daily
                 review
                """)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .minimumScaleFactor(0.5)
        }
        .frame(width: 200, height: 300)
    }
}



extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
