import SwiftUI
import SwiftData

struct ReviewCalendarView: View {
    @Query private var reviews: [Review] // SwiftData에서 리뷰를 자동으로 가져옴
    @Environment(\.modelContext) private var modelContext

    @State private var displayedMonth: Date = Date() // 현재 표시되는 달
    @State private var selectedDate: Date? = nil // 현재 선택된 날짜
    @State private var currentReviewIndex: Int = 0 // 현재 표시 중인 리뷰의 인덱스
    @State private var showFullReview: Bool = false // 전체 리뷰 보기 여부

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

    private var selectedReviews: [Review] {
        guard let selectedDate = selectedDate else { return [] }
        return reviews.filter { calendar.isDate($0.watchDate, inSameDayAs: selectedDate) }
    }

    private func moveMonth(by months: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: months, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func deleteReview(_ review: Review) {
        // 삭제 작업
        modelContext.delete(review)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting review: \(error)")
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
                .padding(.horizontal)

                // 날짜 그리드
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, day in
                        if let day = day {
                            VStack {
                                Text("\(calendar.component(.day, from: day))")
                                    .font(.caption)

                                let dayReviews = reviews.filter { calendar.isDate($0.watchDate, inSameDayAs: day) }

                                if let firstReview = dayReviews.first {
                                    // 날짜에 리뷰가 있으면 첫 번째 리뷰의 포스터 표시
                                    Button(action: {
                                        selectedDate = day // 선택된 날짜 업데이트
                                        currentReviewIndex = 0 // 첫 리뷰로 초기화
                                    }) {
                                        AsyncImageView(_URL: firstReview.movieStorage.poster)
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
                if !selectedReviews.isEmpty {
                    let review = selectedReviews[currentReviewIndex]
                    Button(action: {
                        showFullReview = true // 전체 리뷰 보기 화면으로 전환
                    }) {
                        HStack {
                            // 이전 리뷰 버튼
                            Button(action: {
                                currentReviewIndex = max(0, currentReviewIndex - 1) // 이전 리뷰로 이동
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .disabled(currentReviewIndex == 0) // 첫 리뷰인 경우 비활성화

                            Spacer()

                            // 리뷰 요약 내용
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(review.movieStorage.title)")
                                    .font(.headline)

                                Text(review.reviewText)
                                    .lineLimit(3) // 요약 정보는 3줄까지만 표시
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)

                            Spacer()

                            // 다음 리뷰 버튼
                            Button(action: {
                                currentReviewIndex = min(selectedReviews.count - 1, currentReviewIndex + 1) // 다음 리뷰로 이동
                            }) {
                                Image(systemName: "chevron.right")
                            }
                            .disabled(currentReviewIndex == selectedReviews.count - 1) // 마지막 리뷰인 경우 비활성화
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteReview(review)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showFullReview) {
            if !selectedReviews.isEmpty {
                FullReviewView(review: selectedReviews[currentReviewIndex])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
