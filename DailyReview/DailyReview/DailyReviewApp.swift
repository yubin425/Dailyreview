//
//  DailyReviewApp.swift
//  DailyReview
//
//  Created by 임유빈 on 10/28/24.
//

import SwiftUI
import SwiftData

@main
struct DailyReviewApp: App {
    // SwiftData 모델 컨테이너를 생성
    private var modelContainer: ModelContainer
    
    init() {
        do {
            // 필요한 모든 모델 등록
            self.modelContainer = try ModelContainer(for: Review.self, CustomField.self, MovieStorage.self)
        } catch {
            print("Error creating model container: \(error)")
            fatalError("Failed to create model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let dummyMovie = MovieStorage(
                    id:     UUID(),
                    title: "Dummy Movie Title",
                    director: ["John Doe"],
                    releaseYear: "2023",
                    poster: nil,
                    still: nil,
                    genre: ["Drama", "Thriller"],
                    keyword: ["Suspense", "Mystery"],
                    plotText: "A thrilling tale of suspense and mystery."
                   )
            
            let sampleReviews = [
                Review(movieStorage:dummyMovie, reviewText: "Great movie!", rating: 5, watchDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, watchLocation: "Cinema A", friends: "Alice, Bob"),
                Review(movieStorage:dummyMovie, reviewText: "wowow", rating: 5, watchDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, watchLocation: "my house", friends: "my friends"),
                Review(movieStorage:dummyMovie, reviewText: "Not bad", rating: 3, watchDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, watchLocation: "Cinema B", friends: "Charlie"),
                Review(movieStorage:dummyMovie, reviewText: "Loved it", rating: 4, watchDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, watchLocation: "Cinema C", friends: "Diana, Evan")
            ]
            
            ReviewQueryView(reviews: sampleReviews)
                .modelContainer(modelContainer)
        }
    }

}
