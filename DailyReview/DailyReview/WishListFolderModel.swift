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
    var movies: [MovieStorage] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
    func rename(_ name: String){
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
        for movie in movies {
            if let poster = movie.poster {
                if poster == "" {
                    continue
                }
                return poster
            }
        }
        return nil
    }
    
    func copy() -> WishListFolder {
        let wl = WishListFolder(name: self.name)
        wl.movies = self.movies
        return wl
    }
}


class CodableWL:Codable {
    var name: String
    var movies: [CodableMV] = []
    
    init(wl : WishListFolder) {
        self.name = wl.name
        self.movies = wl.movies.map{ $0.toCodable() }
    }

    func copy() -> WishListFolder {
        let wl = WishListFolder(name: self.name)
        wl.movies = self.movies.map{ $0.toStorage() }
        return wl
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, movies
    }

    // 예시: WishListFolder의 movies 직렬화 시 추가 작업
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        // movies 배열의 각 MovieStorage 객체를 처리
        try container.encode(movies, forKey: .movies) // Directly encode the array of MovieStorage objects
    }

    // Decoding 시
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.movies = try container.decode([CodableMV].self, forKey: .movies)
    }

}
