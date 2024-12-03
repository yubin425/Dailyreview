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
    @State private var modelContext: ModelContext
    
    init() {
        do {
            // 필요한 모든 모델 등록
            self.modelContainer = try ModelContainer(for: Review.self, CustomField.self, MovieStorage.self, WishListFolder.self)
            self.modelContext = ModelContext(self.modelContainer)
        } catch {
            print("Error creating model container: \(error)")
            fatalError("Failed to create model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.modelContext, modelContext)
        }
    }

}
