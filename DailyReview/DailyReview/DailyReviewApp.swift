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
            let dummyMovie = Movie(
                id: UUID(), // UUID 추가
                title: "Dummy Movie Title",
                director: ["John Doe"],
                releaseYear: "2023",
                poster: nil,
                still: nil,
                genre: ["Drama", "Thriller"],
                keyword: ["Suspense", "Mystery"],
                plotText: "A thrilling tale of suspense and mystery."
            )
            ReviewView(movie: dummyMovie)
                .modelContainer(modelContainer)
        }
    }

}
