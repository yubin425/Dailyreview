import SwiftUI

struct ReviewListView: View {
    @State private var selectedReview: Review? = nil // 선택된 리뷰
    @State private var showFullReview: Bool = false // 전체 리뷰 보기 여부
    
    let reviews: [Review]
    @Binding var sortOption: SortOption // sortOption을 Binding으로 받기
    
    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case title = "Title"
        
        var id: String { self.rawValue }
    }
    
    var sortedReviews: [Review] {
        switch sortOption {
        case .date:
            return reviews.sorted { $0.watchDate > $1.watchDate }
        case .title:
            return reviews.sorted { $0.movieTitle < $1.movieTitle }
        }
    }
    
    var body: some View {
        VStack {
            // 리뷰 리스트
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(sortedReviews) { review in
                        Button(action: {
                            selectedReview = review
                            showFullReview = true
                        }) {
                            ReviewSummaryView(review: review)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle()) // 기본 스타일 제거
                    }
                }
            }
        }
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 1) // 툴바와의 간격 확보
        }
        .sheet(isPresented: $showFullReview) {
            if let review = selectedReview {
                FullReviewView(review: review)
            }
        }
    }
}


struct ReviewSummaryView: View {
    let review: Review
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: review.moviePoster)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 90)
                .cornerRadius(5)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(review.watchDate.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(review.movieTitle)
                    .font(.headline)
                    .bold()
                
                Text(review.reviewText)
                    .lineLimit(3)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}


struct ContentView: View {
    @State private var selectedView: ViewOption = .list // 기본은 리스트 뷰
    @State private var sortOption: ReviewListView.SortOption = .date // 초기 정렬 옵션
    let reviews: [Review]
    
    enum ViewOption {
        case calendar, list
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch selectedView {
                case .calendar:
                    ReviewCalendarView(reviews: reviews)
                case .list:
                    ReviewListView(reviews: reviews, sortOption: $sortOption) // sortOption을 전달
                }
            }
            .toolbar {
                // 왼쪽 상단에 정렬 버튼 배치 (list 뷰일 때만 보여짐)
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedView == .list { // 리스트 뷰일 때만 보이도록 조건 추가
                        Button(action: {
                            // 정렬 옵션 변경
                            switch sortOption {
                            case .date:
                                sortOption = .title
                            case .title:
                                sortOption = .date
                            }
                        }) {
                            Text("\(sortOption.rawValue)")
                                .padding(6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(width: 50) // 버튼 크기 문제 해결 필요
                        }
                    }
                }
                
                // 오른쪽 상단에 뷰 전환 버튼
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button(action: { selectedView = .calendar }) {
                            Image(systemName: "calendar")
                                .foregroundColor(selectedView == .calendar ? .blue : .primary)
                        }
                        Button(action: { selectedView = .list }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(selectedView == .list ? .blue : .primary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleReviews = [
        Review(movieTitle: "La La Land", moviePoster: "film", reviewText: "A romantic musical journey.", rating: 5, watchDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, watchLocation: "Cinema A", friends: "Alice, Bob"),
        Review(movieTitle: "Demian", moviePoster: "book", reviewText: "A philosophical story of self-discovery.", rating: 4, watchDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, watchLocation: "Library", friends: "Charlie"),
        Review(movieTitle: "Chicago", moviePoster: "music.mic", reviewText: "A dazzling Broadway show adaptation.", rating: 4, watchDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, watchLocation: "Theater", friends: "Diana, Evan")
    ]
    
    ContentView(reviews: sampleReviews)
}
