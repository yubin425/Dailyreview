import SwiftUI

// Full Review View
struct FullReviewView: View {
    @State var review: Review
    @Environment(\.dismiss) private var dismiss
    @State private var isExpanded = false // 제목 더보기 토글

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                if let stillURL = review.movieStorage.still, !stillURL.isEmpty {
                        AsyncImageView(_URL: stillURL)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .clipped()
                               } else {
                                   LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.white]), //스틸컷 없을 경우
                                       startPoint: .top,
                                       endPoint: .bottom
                                   )
                                   .frame(maxWidth: .infinity, maxHeight: .infinity)
                               }

                // Scrollable Content Overlay
                ScrollView {
                    VStack(spacing: 16) {
                        // Gradient Overlay
                        ZStack(alignment: .topLeading) {
                            // Gradient background with opacity effect
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 100)  // Control the height of the gradient
                            .padding(.top, 200)  // Move gradient down

                            HStack{
                                Text(review.movieStorage.title)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 16)
                                    .padding(.top, 220)
                                    .lineLimit(isExpanded ? nil : 1)
                                Button(action: { isExpanded.toggle() }) {
                                    Text(isExpanded ? "접기" : "...더보기")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                                
                        }


                        // 내용이 적힌 둥근 네모 부분
                        VStack(spacing: 16) {
                            // 포스터 줄거리등 포함된 헤더 뷰
                            ReviewHeaderContentView(review: review)
                            // 유저의 리뷰 작성 항목을 포함
                            ReviewDetailsView(review: review)

                            // 수정하기 버튼
                            NavigationLink(destination: EditReviewView(review: $review)) {
                                Text("수정하기")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.7))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .background(Color.white)
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

    var body: some View {
        VStack(spacing: 16) {
            // Poster and Info
            HStack(spacing: 16) {
                AsyncImageView(_URL: review.movieStorage.poster)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 8) {
                    Text(review.movieStorage.title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)

                    Text("\(review.movieStorage.director.first ?? "Unknown"), \(review.movieStorage.releaseYear ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Expandable Plot Text
                    if let plot = review.movieStorage.plotText, plot != "" {
                        Text(plot)
                            .lineLimit(isExpanded ? nil : 3)
                            .font(.body)
                            .foregroundColor(.black)

                            Button(action: { isExpanded.toggle() }) {
                                Text(isExpanded ? "접기" : "...더보기")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                    }

                    // Rating
                    StarRatingView(rating: review.rating)

                    // Tags
                    Text(Tags)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
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
                Text("📅 날짜: \(review.watchDate.formatted(date: .long, time: .omitted))")
                Text("📍 위치: \(review.watchLocation)")
                Text("👥 친구들: \(review.friends)")
            }
            .font(.subheadline)

            Divider()

            // Custom Fields Section
            if let customFields = review.customFields, !customFields.isEmpty {
                Text("Custom Fields:")
                    .font(.headline)

                ForEach(customFields) { field in
                    HStack {
                        Text("\(field.name):")
                            .bold()
                        Text(field.value)
                    }
                }
            } else {
                Text("No custom fields added.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Divider()

            // Review Text
            Text("Review:")
                .font(.headline)
            Text(review.reviewText)
                .font(.body)
        }
        .padding()
    }
}


struct EditReviewView: View {
    @Binding var review: Review // 수정할 Review를 바인딩

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // 이전 화면으로 복귀를 위한 dismiss 환경 변수

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

                    // 커스텀 필드 관리
                    customFieldsSection()

                    // 리뷰 입력창
                    reviewTextEditorToggle()

                    Spacer()

                    // 저장 및 취소 버튼
                    actionButtons()
                }
            }
            .onAppear {
                initializeLocalState()
            }
        }
        .navigationBarBackButtonHidden()
    }

    @ViewBuilder
    private func movieHeaderView() -> some View {
        GeometryReader { geometry in
            VStack {
                AsyncImageView(_URL: review.movieStorage.still)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 300)
                    .clipped()
                    .overlay(Color.white.opacity(0.7))
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
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.bottom, 5)
                                    Text("\(String(review.movieStorage.director.first ?? "null")),\(String(review.movieStorage.releaseYear ?? "null"))")
                                    Text("\(String(review.movieStorage.plotText ?? "null"))")
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
                                Text("출연자:\(String(review.movieStorage.actor.first ?? "null"))")
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("👥 사람")
                Divider()
                TextField("영화를 같이 본 친구", text: $friends)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
    }

    @ViewBuilder
    private func customFieldsSection() -> some View {
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
        .padding()
    }

    @ViewBuilder
    private func reviewTextEditorToggle() -> some View {
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
        }
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
            .foregroundColor(.white)
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

    private func addCustomField() {
        guard !newFieldName.isEmpty else { return }
        customFields.append(CustomField(name: newFieldName, value: ""))
        newFieldName = ""
    }

    private func resetCustomFields() {
        customFields.removeAll()
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
