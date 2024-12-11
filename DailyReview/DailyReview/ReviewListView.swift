import SwiftUI
import SwiftData

struct ReviewListView: View {
    @State private var navigateToEditView = false
    @State private var selectedReview: Review? = nil // 선택된 리뷰
    @State private var showFullReview: Bool = false // 전체 리뷰 보기 여부
    
    let reviews: [Review]
    @Binding var sortOption: SortOption // sortOption을 Binding으로 받기
    
    enum SortOption: String, CaseIterable, Identifiable {
        case dateAs = "Date↑"
        case dateDs = "Date↓"
        case titleAs = "Title↑"
        case titleDs = "Title↓"
        
        var id: String { self.rawValue }
    }
    
    var sortedReviews: [Review] {
        switch sortOption {
        case .dateAs:
            return reviews.sorted { $0.watchDate > $1.watchDate }
        case .dateDs:
            return reviews.sorted { $0.watchDate < $1.watchDate }
        case .titleAs:
            return reviews.sorted { $0.movieStorage.title < $1.movieStorage.title }
        case .titleDs:
            return reviews.sorted { $0.movieStorage.title > $1.movieStorage.title }
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
                    .presentationDragIndicator(.visible)
            }
        }
    }
}


struct ReviewSummaryView: View {
    let review: Review
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AsyncImageView(_URL: review.movieStorage.poster)
                .scaledToFit()
                .frame(width: 60, height: 90)
                .cornerRadius(5)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(review.watchDate.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(review.movieStorage.title)
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


struct ReviewQueryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reviews: [Review]
    @State private var selectedView: ViewOption = .list // 기본은 리스트 뷰
    @State private var sortOption: ReviewListView.SortOption = .dateAs // 초기 정렬 옵션
    
    enum ViewOption {
        case calendar, list
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch selectedView {
                case .calendar:
                    ReviewCalendarView()
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
                            case .dateAs:
                                sortOption = .dateDs
                            case .dateDs:
                                sortOption = .titleAs
                            case .titleAs:
                                sortOption = .titleDs
                            case .titleDs:
                                sortOption = .dateAs
                            }
                        }) {
                            Text("\(sortOption.rawValue)")
                                .padding(6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(width: 70) // 버튼 크기 문제 해결 필요
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

