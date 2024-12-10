//
//  StaticsView.swift
//  DailyReview
//
//  Created by 2022049898 on 12/2/24.
//

import SwiftUI
import Combine

struct StatisticsView: View {
    @State private var statistics: [String] = []
    @State private var isLoading = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var allReviews: [Review]  // This will hold the list of reviews
    
    init(reviews: [Review]) {
        self.allReviews = reviews
        _statistics = State(initialValue: generateStatistics(reviews: reviews))  // Initialize statistics
    }
    
    var body: some View {
        VStack {
            // Show loading indicator while fetching most-watched genre
            if isLoading {
                ProgressView("로딩중.")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                // Randomly select two unique statistics to display
                let randomStatistics = statistics.shuffled().prefix(2)
                
                ForEach(randomStatistics, id: \.self) { stat in
                    NotificationBlock(message: stat)
                }
            }
        }
        .padding()
        .onAppear {
            // Generate statistics when view appears
            mostWatchedGenre()
        }
    }
    
    // Generate all statistics based on the reviews
    private func generateStatistics(reviews: [Review]) -> [String] {
        var stats: [String] = []
        
        // Movies Watched This Month
        let watchedThisMonth = moviesWatchedThisMonth(reviews: reviews)
        stats.append("이번 달에 본 영화 갯수는 \(watchedThisMonth)개에요")
        
        // Best Rated Movie
        let bestRated = bestRatedMovie(reviews: reviews)
        stats.append(bestRated)
        
        // Most Watched Genre
        stats.append("가장 많이 본 영화 장르는 Unknown입니다")  // Placeholder
        
        // Most Recent Review
        let recentReview = mostRecentReview(reviews: reviews)
        stats.append(recentReview)
        
        return stats
    }
    
    // Movies Watched This Month
    private func moviesWatchedThisMonth(reviews: [Review]) -> Int {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let filteredReviews = reviews.filter { review in
            let reviewMonth = Calendar.current.component(.month, from: review.watchDate)
            let reviewYear = Calendar.current.component(.year, from: review.watchDate)
            return reviewMonth == currentMonth && reviewYear == currentYear
        }
        
        return filteredReviews.count
    }
    
    // Best Rated Movie
    private func bestRatedMovie(reviews: [Review]) -> String {
        guard let bestRatedReview = reviews.max(by: { $0.rating < $1.rating }) else {
            return "아직 평점을 매긴 영화가 없어요"
        }

        let movieTitle = bestRatedReview.movieStorage.title
        let rating = bestRatedReview.rating

        // Create the star string for the rating
        let filledStars = String(repeating: "★", count: rating)  // Full stars
        let emptyStars = String(repeating: "☆", count: 5 - rating)  // Empty stars for 5-star scale

        // Combine the title with the star ratings
        return "가장 높은 평가를 준 영화는 \(movieTitle)이에요 \(filledStars)\(emptyStars)"
    }

    
    // Fetch and compute Most Watched Genre
    private func mostWatchedGenre() {
        isLoading = true
        
        // Get genres from all reviews
        let genres = allReviews.flatMap { review in
            return review.movieStorage.genre
        }
        
        // Calculate the frequency of each genre
        var genreCount = [String: Int]()
        for genre in genres {
            genreCount[genre, default: 0] += 1
        }
        
        // Find the most watched genre
        let mostWatched = genreCount.max { $0.value < $1.value }
        let mostWatchedGenre = mostWatched?.key ?? "Unknown"
        
        // Update statistics
        if let index = statistics.firstIndex(of: "가장 많이 본 영화 장르는 Unknown입니다") {
            statistics[index] = "가장 많이 본 영화 장르는 \(mostWatchedGenre)입니다"
        }
        
        // Stop loading
        isLoading = false
    }
    
    // Most Recent Review
    private func mostRecentReview(reviews: [Review]) -> String {
        guard let recentReview = reviews.max(by: { $0.watchDate < $1.watchDate }) else {
            return "아직 작성된 리뷰가 없어요"
        }
        
        let movieTitle = recentReview.movieStorage.title
        let writtenDate = formatDate(recentReview.watchDate)
        
        return "가장 최근에 작성된 리뷰는 \(movieTitle)이고, 작성일자는 \(writtenDate)입니다."
    }
    
    // Helper function to format the date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

