import SwiftUI
import SwiftData

extension String {
    func splitWord() -> String {
        return self.split(separator: "").joined(separator: "\u{200B}")
    }
}


// Full Review View
struct FullReviewView: View {
    @State var review: Review
    @Environment(\.dismiss) private var dismiss
    @State private var isExpanded = false // 제목 더보기 토글
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    
    private func deleteReview() {
        if let customFields = review.customFields {
            for field in customFields {
                modelContext.delete(field) // 커스텀 필드 삭제
            }
        }
        modelContext.delete(review) // 리뷰 삭제
        dismiss() // 화면 닫기
    }


    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                
                
                GeometryReader { geometry in
                    if let stillURL = review.movieStorage.still, !stillURL.isEmpty {
                        AsyncImageView(_URL: stillURL)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: isDarkMode ? [Color.red,Color.black] : [Color.red,Color.white]), //스틸컷 없을 경우
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                // Scrollable Content Overlay
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Gradient Overlay
                        ZStack(alignment: .topLeading) {
                            // Gradient background with opacity effect
                            LinearGradient(
                                gradient: Gradient(colors: isDarkMode ? [Color.black.opacity(0.0),Color.black] : [Color.white.opacity(0.0), Color.white]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 100)  // Control the height of the gradient
                            .padding(.top, 200)  // Move gradient down

                            HStack{
                                Text(review.movieStorage.title)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(isDarkMode ? Color.white : Color.black)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 16)
                                    .padding(.top, 220)
                                    .lineLimit(1)

                            }
                                
                        }


                        // 내용이 적힌 둥근 네모 부분
                        VStack(alignment: .center, spacing: 16) {
                            HStack{
                                Spacer()
                                NavigationLink(destination: EditReviewView(review: $review)) {
                                    Image(systemName: "square.and.pencil")
                                        .font(.headline)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    showDeleteAlert = true // 경고창 표시
                                }) {
                                    Image(systemName: "trash.fill")
                                        .font(.headline)
                                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .alert(isPresented: $showDeleteAlert) {
                                    Alert(
                                        title: Text("리뷰 삭제"),
                                        message: Text("이 리뷰를 정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다."),
                                        primaryButton: .destructive(Text("삭제")) {
                                            deleteReview() // 리뷰 삭제
                                        },
                                        secondaryButton: .cancel(Text("취소"))
                                    )
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            // 포스터 줄거리등 포함된 헤더 뷰
                            ReviewHeaderContentView(review: review)
                            // 유저의 리뷰 작성 항목을 포함
                            ReviewDetailsView(review: review)
                        }
                        .background(isDarkMode ? Color.black : Color.white)
                        .cornerRadius(16)
                        //.padding(.horizontal)
                        .padding(.top, -50)
                    }
                }
                
                
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReviewHeaderContentView: View {
    let review: Review
    @State private var isExpanded = false // 줄거리 더보기 토글
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        VStack(spacing: 16) {
            // Poster and Info
            
            HStack(spacing: 16) {
                AsyncImageView(_URL: review.movieStorage.poster)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .cornerRadius(8)
                
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text(review.movieStorage.title)
                        .font(.headline)
                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                        .multilineTextAlignment(.leading)

                    Text("\(review.movieStorage.director.first ?? "Unknown"), \(review.movieStorage.releaseYear ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Rating
                    StarRatingView(rating: review.rating)

                    // Tags
                    Text(Tags)
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .padding(.horizontal)
            if let plot = review.movieStorage.plotText, !plot.isEmpty {
                ZStack(alignment: .bottomTrailing) {
                    Text(plot.splitWord())
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 3)
                        .font(.body)
                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if !isExpanded {
                        LinearGradient(
                            gradient: Gradient(colors: isDarkMode ? [Color.black.opacity(0), Color.black] : [Color.white.opacity(0), Color.white]),
                            startPoint: .center,
                            endPoint: .trailing
                        )
                        .frame(height: 20) // 그라데이션 높이 설정
                        .allowsHitTesting(false) // 터치 이벤트 무시

                        HStack {
                            Spacer()
                            Button(action: { isExpanded.toggle() }) {
                                Text("...더보기")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.trailing, 8) // 버튼 여백 추가
                        }
                    }
                }
            }
        

        }
        .padding()
    }

    // Movie Tags (Genre and Keywords)
    private var Tags: String {
        let genreTags = review.movieStorage.genre.prefix(2).map { "#\($0)" }
        let keywordTag = review.movieStorage.keyword.prefix(1).map { "#\($0)" }
        return (genreTags + keywordTag).joined(separator: " ")
    }
}


struct GradientOverlay: View {
    let isVisible: Bool

    var body: some View {
        if isVisible {
            LinearGradient(
                gradient: Gradient(colors: [.clear, Color.white.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 40)
        }
    }
}

// Star Rating View
struct StarRatingView: View {
    let rating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(index <= rating ? .orange : .black)
            }
        }
    }
}

struct ReviewDetailsView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Divider()
                Text("📅 날짜: \(review.watchDate.formatted(date: .long, time: .omitted))")
                if review.watchLocation != ""{
                    Text("📍 위치: \(review.watchLocation)")
                }
                if review.friends != ""{
                    Text("👥 사람: \(review.friends)")
                }
            }
            .font(.subheadline)


            // Custom Fields Section
            if let customFields = review.customFields, !customFields.isEmpty {
                Divider()
                ForEach(customFields) { field in
                    HStack {
                        Text("\(field.name):")
                            .font(.subheadline)
                        Text(field.value)
                            .font(.subheadline)
                    }
                }
            } else {

            }

            if review.reviewText != ""{
                Divider()
                // Review Text
                Text("Review:")
                    .font(.headline)
                Text(review.reviewText)
                    .font(.body)
            }
            Spacer()
            Spacer()
            Spacer()
        }
        .padding()
    }
}

// MARK: - EditReviewView
struct EditReviewView: View {
    @Binding var review: Review // 수정할 Review를 바인딩

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // 이전 화면으로 복귀를 위한 dismiss 환경 변수
    @Environment(\.colorScheme) private var colorScheme

    // 로컬 상태
    @State private var reviewText = ""
    @State private var rating = 1
    @State private var watchDate = Date()
    @State private var watchLocation = ""
    @State private var friends = ""
    @State private var customFields: [CustomField] = []

    // 새 필드 추가 관련 상태
    @State private var newFieldName: String = ""

    // 리뷰 입력창 표시 여부
    @State private var showReviewField = false
    
    @State private var isExpanded = false

    // 커스텀 필드 레이아웃
    @State private var savedLayouts: [CustomFieldLayout] = []
    @State private var selectedLayout: CustomFieldLayout? = nil
    @State private var showSaveLayoutModal = false
    @State private var newLayoutName: String = ""
    
    //이미지 커스텀 관련 변수
    @State private var showImageOptions = false
    @State private var isSelectingPoster = false
    @State private var isSelectingStill = false
    @State private var selectedImage: UIImage?
    
    private var Tags: String {
        let genreTags = review.movieStorage.genre.prefix(2).map { "#\($0)" }
        let keywordTag = review.movieStorage.keyword.prefix(1).map { "#\($0)" }
        return (genreTags + keywordTag).joined(separator: " ")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    // 이미지 및 영화 기본 정보
                    movieHeaderView()

                    // 기본 정보 입력
                    reviewDetailsForm()
                    
                    Divider()

                    // 커스텀 필드 관리
                    customFieldsSection()
                    
                    Divider()

                    // 리뷰 입력창
                    reviewTextEditor()
                    
                    Divider()

                    Spacer()
                }
            }
            .onAppear {
                initializeLocalState()
                fetchSavedLayouts()
            }
            // 저장 및 취소 버튼
            actionButtons()
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Subviews
    
    
    @ViewBuilder
    private func movieHeaderView() -> some View {
        GeometryReader { geometry in
            VStack {
                AsyncImageView(_URL: review.movieStorage.still)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 270)
                    .clipped()
                    .overlay(
                        Color(colorScheme == .dark ? .black : .white)
                            .opacity(0.7) // 다크 모드에 따라 색상 반전
                    )
                    .overlay(
                        VStack(alignment: .center) {
                            HStack {
                                AsyncImageView(_URL: review.movieStorage.poster)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150)
                                    .padding(.horizontal)
                                Spacer()
                                
                                VStack {
                                    Text("\(review.movieStorage.title)")
                                        .font(.title)
                                        .foregroundColor(colorScheme == .dark ? .white : .black) // 다크 모드 색상
                                        .multilineTextAlignment(.center)
                                        .padding(.bottom, 5)
                                    
                                    Text("\(String(review.movieStorage.director.first ?? "null")),\(String(review.movieStorage.releaseYear ?? "null"))")
                                        .foregroundColor(colorScheme == .dark ? .gray : .black) // 텍스트 색상 반전
                                    
                                    HStack {
                                        ForEach(1...5, id: \.self) { index in
                                            Image(systemName: index <= rating ? "star.fill" : "star")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(index <= rating ? .orange : (colorScheme == .dark ? .white : .black))
                                                .onTapGesture {
                                                    rating = index
                                                }
                                        }
                                    }
                                    
                                    Text("출연자:\(String(review.movieStorage.actor.first ?? "null"))")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(colorScheme == .dark ? .gray : .black)
                                    
                                    Text(Tags)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(colorScheme == .dark ? .gray : .black)
                                    
                                }
                                .padding(.horizontal)
                            }
                        }
                    )
            }
        }
        .background(Color(colorScheme == .dark ? .black : .white).opacity(0.3))
        .padding(.vertical)
        .frame(height: 300)
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
                    Text("선택된 레이아웃 없음")
                        .foregroundColor(.red)
                        .tag(nil as CustomFieldLayout?)
                    ForEach(savedLayouts, id: \.id) { layout in
                        Text(layout.name)
                            .foregroundColor(.red)
                            .tag(layout as CustomFieldLayout?)
                    }
                }
                .tint(.red)
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
             Button("저장") {
                 saveChanges()
                 dismiss()
             }
             .frame(maxWidth: .infinity)
             .padding()
             .background(Color.red.opacity(0.7))
             .foregroundColor(.white)
             .cornerRadius(8)
             
             Button("취소") {
                 dismiss()
             }
             .frame(maxWidth: .infinity)
             .padding()
             .background(Color.gray.opacity(0.7))
             .foregroundColor(colorScheme == .dark ? .black : .white)
             .cornerRadius(8)
         }
         .padding()
     }

    
    

    private func initializeLocalState() {
        reviewText = review.reviewText
        rating = review.rating
        watchDate = review.watchDate
        watchLocation = review.watchLocation
        friends = review.friends
        customFields = review.customFields ?? []
    }

    private func saveChanges() {
        review.reviewText = reviewText
        review.rating = rating
        review.watchDate = watchDate
        review.watchLocation = watchLocation
        review.friends = friends
        review.customFields = customFields
    }
}

// MARK: - Helper Methods

extension EditReviewView {
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
