import SwiftUI

struct ReviewCalendarView: View {
    @State private var navigateToEditView = false
    @State private var displayedMonth: Date = Date() // 현재 표시되는 달
    @State private var selectedReview: Review? = nil // 선택된 리뷰
    @State private var showFullReview: Bool = false // 전체 리뷰 보기 여부
    
    let reviews: [Review]
    let calendar = Calendar.current
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // "October 2023" 형식
        return formatter
    }
    
    private var daysInMonth: [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstDayOfMonth = calendar.component(.weekday, from: startOfMonth) - 1
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let adjustedDays = Array(repeating: nil, count: firstDayOfMonth) + range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
        return adjustedDays
    }
    
    private func moveMonth(by months: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: months, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // 월 변경 버튼
                HStack {
                    Button(action: { moveMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(monthYearFormatter.string(from: displayedMonth))
                        .font(.title)
                        .bold()
                    Spacer()
                    Button(action: { moveMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // 요일 헤더
                let weekdaySymbols = calendar.shortWeekdaySymbols
                HStack {
                    ForEach(weekdaySymbols, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .bold()
                    }
                }
                
                // 날짜 그리드
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(daysInMonth, id: \.self) { day in
                        if let day = day {
                            VStack {
                                Text("\(calendar.component(.day, from: day))")
                                    .font(.caption)
                                
                                if let review = reviews.first(where: { calendar.isDate($0.watchDate, inSameDayAs: day) }) {
                                    // 리뷰가 있는 날짜에 포스터 표시
                                    Button(action: {
                                        selectedReview = review // 요약 정보만 설정
                                    }) {
                                        Image(review.movieStorage.poster ?? "testImage")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40.5, height: 60)
                                            .cornerRadius(5)
                                    }
                                } else {
                                    // 리뷰가 없는 날짜는 빈 공간
                                    Text("")
                                        .frame(width: 40.5, height: 60)
                                        .background(Color.gray.opacity(0.2))
                                }
                            }
                            .frame(width: 60, height: 80)
                        } else {
                            Text("")
                                .frame(width: 60, height: 80)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 리뷰 요약 정보 표시
                if let review = selectedReview {
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            showFullReview = true // 전체 리뷰 보기 화면으로 전환
                        }) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(review.movieStorage.title)")
                                    .font(.headline)
                                
                                Text(review.reviewText)
                                    .lineLimit(3) // 요약 정보는 3줄까지만 표시
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $showFullReview) {
            if let review = selectedReview {
                FullReviewView(review: review)
            }
        }
    }
}



//#Preview {
//    let dummyMovie = MovieStorage(
//            id:     UUID(),
//            title: "Dummy Movie Title",
//            director: ["John Doe"],
//            releaseYear: "2023",
//            poster: nil,
//            still: nil,
//            genre: ["Drama", "Thriller"],
//            keyword: ["Suspense", "Mystery"],
//            plotText: "A thrilling tale of suspense and mystery."
//           )
//    
//    let sampleReviews = [
//        Review(movieStorage:dummyMovie, reviewText: "Great movie!", rating: 5, watchDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, watchLocation: "Cinema A", friends: "Alice, Bob"),
//        Review(movieStorage:dummyMovie, reviewText: "Not bad", rating: 3, watchDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, watchLocation: "Cinema B", friends: "Charlie"),
//        Review(movieStorage:dummyMovie, reviewText: "Loved it", rating: 4, watchDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, watchLocation: "Cinema C", friends: "Diana, Evan")
//    ]
//    
//    ReviewQueryView(reviews: sampleReviews)
//}
