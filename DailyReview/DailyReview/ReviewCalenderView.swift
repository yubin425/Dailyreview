import SwiftUI

struct ReviewCalendarView: View {
    @State private var displayedMonth: Date = Date() // 현재 표시되는 달
    let reviews: [Review]
    let calendar = Calendar.current
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // "October 2023" 형식
        return formatter
    }
    
    private var daysInMonth: [Date?] {
        // 현재 표시된 월의 첫 번째 날짜
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        
        // 첫 번째 날이 어떤 요일인지 계산 (1: 일요일, 7: 토요일)
        let firstDayOfMonth = calendar.component(.weekday, from: startOfMonth) - 1
        
        // 해당 월의 날짜 범위 (1일부터 마지막일까지)
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        // 첫 번째 날짜가 표시될 위치를 맞추기 위해 빈 날짜들을 추가
        let adjustedDays = Array(repeating: nil, count: firstDayOfMonth) + range.compactMap { day in
            calendar.date(byAdding: .day, value: day-1, to: startOfMonth)
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
                // 상단 월 표시 및 이전/다음 버튼
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
                
                GeometryReader { geometry in
                    VStack{
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
                        
                        //Text("\(daysInMonth)")
                        
                        // 날짜 그리드
                        let columns = Array(repeating: GridItem(.flexible()), count: 7)
                        LazyVGrid(columns: columns, spacing:10) {
                            ForEach(daysInMonth, id: \.self) { day in
                                if let day = day { // nil을 제외하고 유효한 날짜만 표시
                                    VStack {
                                        if let review = reviews.first(where: { calendar.isDate($0.watchDate, inSameDayAs: day) }) {
                                            
                                            VStack{
                                                Text("\(calendar.component(.day, from: day))")
                                                    .font(.caption)
                                                // 리뷰가 있는 날짜에 영화 포스터 이미지 표시
                                                Image(systemName: "film") // 영화 포스터 이미지를 나타내는 임시 아이콘
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40.5, height: 60)
                                                    .cornerRadius(5)
                                            }
                                        } else {
                                            // 리뷰가 없는 날짜는 기본 날짜만 표시
                                            VStack{
                                                Text("\(calendar.component(.day, from: day))")
                                                    .font(.caption)
                                                Text("")
                                                    .frame(width: 40.5, height: 60)
                                                    .background(
                                                        calendar.isDateInToday(day) ? Color.red.opacity(0.3) : Color.gray.opacity(0.2) // 오늘 날짜 강조
                                                    )
                                                    .cornerRadius(2)
                                            }
                                        }
                                    }
                                    .frame(width: 60, height: 80)
                                } else {
                                    Text("")
                                        .frame(width: 60, height: 80)
                                }
                            }//grid
                        }//vstack
                    }//geomerty
                }
                
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    // 임의의 리뷰 데이터로 프리뷰 생성
    let sampleReviews = [
        Review(movieTitle: "Movie A", moviePoster: "film", reviewText: "Great movie!", rating: 5, watchDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, watchLocation: "Cinema A", friends: "Alice, Bob",customFields: []),
        Review(movieTitle: "Movie B", moviePoster: "star", reviewText: "Not bad", rating: 3, watchDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, watchLocation: "Cinema B", friends: "Charlie", customFields: []),
        Review(movieTitle: "Movie C", moviePoster: "star.fill", reviewText: "Loved it", rating: 4, watchDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, watchLocation: "Cinema C", friends: "Diana, Evan",customFields: [])
    ]
    
    ReviewCalendarView(reviews: sampleReviews)
}
