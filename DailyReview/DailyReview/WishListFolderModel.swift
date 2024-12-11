//
//  WishListFolderModel.swift
//  DailyReview
//
//  Created by Lee Hyun on 11/17/24.
//

import SwiftUI
import SwiftData

@Model
class WishListFolder:Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship var movies:[MovieStorage] = []
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
    func addMovie(_ movie: MovieStorage) {
        if !movies.contains(where: { $0.id == movie.id }) {
            movies.append(movie)
        }
    }

    // 영화 제거
    func removeMovie(_ movie: MovieStorage) {
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies.remove(at: index)
        }
    }

    // 대표 포스터 가져오기
    func getPoster() -> String? {
        return movies.first?.poster
    }
}
