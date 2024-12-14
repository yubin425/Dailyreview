//
//  StatisticsView.swift
//  DailyReview
//
//  Created by 2022049898 on 12/2/24.
//

import SwiftUI
import Combine

struct StatisticsView: View {
    @State private var statistics: [String]
    @State private var isLoading = false
    @State private var hiddenStatistics: [String] = []
    @State private var showModal = false
    @State private var selectedStatistic: String? = nil
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    var allReviews: [Review]

    init(reviews: [Review]) {
        self.allReviews = reviews
        _statistics = State(initialValue: StatisticsView.generateStatistics(reviews: reviews))
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("로딩중.")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                if statistics.isEmpty || hiddenStatistics.count == statistics.count {
                    StaticsBlock(message: "더 많은 리뷰를 기록해주세요!")
                } else {
                    ForEach(displayedStatistics, id: \ .self) { stat in
                        if !hiddenStatistics.contains(stat) {
                            StaticsBlock(message: stat)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation {
                                                hiddenStatistics.append(stat)
                                            }
                                        }) {
                                            Text("x")
                                                .foregroundColor(.red)
                                                .padding()
                                        }
                                    }
                                )
                                .onTapGesture {
                                    selectedStatistic = stat
                                    showModal = true
                                }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            mostWatchedGenre()
            hiddenStatistics.removeAll()
        }
        .sheet(isPresented: $showModal) {
            if let selectedStatistic = selectedStatistic {
                StatisticDetailView(statistic: selectedStatistic, reviews: allReviews)
            }
        }
    }

    private var displayedStatistics: [String] {
        statistics.filter { !hiddenStatistics.contains($0) }.prefix(2).map { $0 }
    }

    private func showDetails(for stat: String) {
        if stat.contains("최근에 작성된 리뷰") {
            if let recentReview = allReviews.max(by: { $0.watchDate < $1.watchDate }) {
                print("Navigate to review for \(recentReview.movieStorage.title)")
            }
        } else {
            print("Show more details for \(stat)")
        }
    }

    private static func generateStatistics(reviews: [Review]) -> [String] {
        var stats: [String] = []
        
        let watchedThisMonth = moviesWatchedThisMonth(reviews: reviews)
        stats.append("이번 달에 본 영화 갯수는 \(watchedThisMonth)개에요")
        
        let bestRated = bestRatedMovie(reviews: reviews)
        stats.append(bestRated)
        
        stats.append("가장 많이 본 영화 장르는 Unknown입니다")
        
        let recentReview = mostRecentReview(reviews: reviews)
        stats.append(recentReview)
        
        return stats
    }

    private static func moviesWatchedThisMonth(reviews: [Review]) -> Int {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let filteredReviews = reviews.filter { review in
            let reviewMonth = Calendar.current.component(.month, from: review.watchDate)
            let reviewYear = Calendar.current.component(.year, from: review.watchDate)
            return reviewMonth == currentMonth && reviewYear == currentYear
        }
        
        return filteredReviews.count
    }

    private static func bestRatedMovie(reviews: [Review]) -> String {
        guard let bestRatedReview = reviews.max(by: { $0.rating < $1.rating }) else {
            return "아직 평점을 매긴 영화가 없어요"
        }

        let movieTitle = bestRatedReview.movieStorage.title
        let rating = bestRatedReview.rating

        let filledStars = String(repeating: "★", count: rating)
        let emptyStars = String(repeating: "☆", count: 5 - rating)

        return "가장 높은 평가를 준 영화는 \(movieTitle)(이)에요 \(filledStars)\(emptyStars)"
    }

    private func mostWatchedGenre() {
        isLoading = true
        let genres = allReviews.flatMap { $0.movieStorage.genre }
        
        var genreCount = [String: Int]()
        for genre in genres {
            genreCount[genre, default: 0] += 1
        }

        let mostWatched = genreCount.max { $0.value < $1.value }
        let mostWatchedGenre = mostWatched?.key ?? "Unknown"

        if let index = statistics.firstIndex(of: "가장 많이 본 영화 장르는 Unknown입니다") {
            statistics[index] = "가장 많이 본 영화 장르는 \(mostWatchedGenre)입니다"
        }

        isLoading = false
    }

    private static func mostRecentReview(reviews: [Review]) -> String {
        guard let recentReview = reviews.max(by: { $0.watchDate < $1.watchDate }) else {
            return "아직 작성된 리뷰가 없어요"
        }

        let movieTitle = recentReview.movieStorage.title
        let writtenDate = formatDate(recentReview.watchDate)

        return "가장 최근에 작성된 리뷰는 \(movieTitle)이고, 작성일자는 \(writtenDate)이에요."
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct StaticsBlock: View {
    let message: String
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isDarkMode ? [Color.white.opacity(0.2), Color.black.opacity(0.3)] : [Color.white.opacity(0.5), Color.gray.opacity(0.1), ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

            Text(message)
                .font(.headline)
                .padding()
                .foregroundColor(Color("TextColor"))
        }
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct StatisticDetailView: View {
    let statistic: String
    let reviews: [Review]

    var body: some View {
        VStack {
            Text("\(statistic)")
                .font(.title)
                .padding()

            Spacer()
        }
        .padding()
    }
}
