// Movie.swift
import Foundation
import SwiftData

// 영화의 핵심 정보를 담은 구조체
struct Movie: Decodable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let director: [String]
    let releaseYear: String?
    let poster: String?
    let still: String?
    let genre: [String]
    let keyword: [String]
    let plotText: String?
    let actor: [String]
    
    init(id: UUID = UUID(), title: String, director: [String], releaseYear: String? = nil, poster: String? = nil, still: String? = nil, genre: [String], keyword: [String], plotText: String? = nil, actor: [String]) {
        self.id = id
        self.title = Movie.cleanStr(from: title)
        self.director = director
        self.releaseYear = releaseYear
        self.poster = Movie.extractFirst(from: poster)?.replacingOccurrences(of: "http://", with: "https://")
        self.still = Movie.extractFirst(from: still)?.replacingOccurrences(of: "http://", with: "https://")
        self.genre = genre
        self.keyword = keyword
        self.plotText = plotText
        self.actor = actor
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func cleanStr(from str: String) -> String {
        var cleanedStr = str
        cleanedStr = cleanedStr.replacingOccurrences(of: " !HS ", with: "")
        cleanedStr = cleanedStr.replacingOccurrences(of: " !HE ", with: "")
        return cleanedStr
    }
    
    static func extractFirst(from image: String?) -> String? {
        return image?.components(separatedBy: "|").first
    }

    // API가 주는 key
    enum CodingKeys: String, CodingKey {
        case title
        case directors
        case actors
        case prodYear
        case posters
        case stlls
        case genre
        case keyword
        case plotText = "plots"
    }
    
    enum DirectorsCodingKeys: String, CodingKey {
        case director
    }
    
    enum ActorsCodingKeys: String, CodingKey {
        case actor
    }
    
    enum PlotCodingKeys: String, CodingKey {
        case plot
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = Movie.cleanStr(from: try container.decode(String.self, forKey: .title))
        
        // Director 정보 추출
        let directorsContainer = try container.nestedContainer(keyedBy: DirectorsCodingKeys.self, forKey: .directors)
        let directors = try directorsContainer.decode([Director].self, forKey: .director)
        let director = directors.map { Movie.cleanStr(from: $0.directorNm) }
        
        let actorsContainer = try container.nestedContainer(keyedBy: ActorsCodingKeys.self, forKey: .actors)
        let actors = try actorsContainer.decode([Actor].self, forKey: .actor)
        let actor = actors.map { Movie.cleanStr(from: $0.actorNm) }
        
        // Genre와 Keyword 정보를 콤마로 나누어 리스트로 변환
        let genre = try container.decode(String.self, forKey: .genre).components(separatedBy: ",")
        let keyword = try container.decodeIfPresent(String.self, forKey: .keyword)?.components(separatedBy: ",") ?? []
        
        let releaseYear = try container.decodeIfPresent(String.self, forKey: .prodYear)
        
        // 포스터와 스틸 이미지의 첫 번째 이미지 URL만 추출
        let poster = Movie.extractFirst(from: try container.decodeIfPresent(String.self, forKey: .posters))?.replacingOccurrences(of: "http://", with: "https://")
        let still = Movie.extractFirst(from: try container.decodeIfPresent(String.self, forKey: .stlls))?.replacingOccurrences(of: "http://", with: "https://")
        
        // PlotText 정보 추출
        let plotContainer = try container.nestedContainer(keyedBy: PlotCodingKeys.self, forKey: .plotText)
        let plots = try plotContainer.decode([Plot].self, forKey: .plot)
        let plotText = plots.first?.plotText

        self.init(title: title, director: director, releaseYear: releaseYear, poster: poster, still: still, genre: genre, keyword: keyword, plotText: plotText, actor:actor)
    }
    func toStorage() -> MovieStorage {
        let MS = MovieStorage(
                id:     UUID(),
                title: self.title,
                director: self.director,
                releaseYear: self.releaseYear,
                poster: self.poster,
                still: self.still,
                genre: self.genre,
                keyword: self.keyword,
                plotText: self.plotText,
                actor: self.actor
               )
        return MS
    }
}

struct Director: Codable {
    let directorNm: String
}

struct Actor: Codable {
    let actorNm: String
}

struct Plot: Codable {
    let plotLang: String
    let plotText: String
}


@Model
class MovieStorage: ObservableObject, Identifiable {
    var id: UUID
    var title: String
    var director: [String]
    var releaseYear: String?
    var poster: String?
    var still: String?
    var genre: [String]
    var keyword: [String]
    var plotText: String?
    var actor: [String]
    
    
    init(id: UUID, title: String, director: [String], releaseYear: String? = nil, poster: String? = nil, still: String? = nil, genre: [String], keyword: [String], plotText: String? = nil, actor: [String]) {
        self.id = id
        self.title = Movie.cleanStr(from: title)
        self.director = director
        self.releaseYear = releaseYear
        self.poster = Movie.extractFirst(from: poster)?.replacingOccurrences(of: "http://", with: "https://")
        self.still = Movie.extractFirst(from: still)?.replacingOccurrences(of: "http://", with: "https://")
        self.genre = genre
        self.keyword = keyword
        self.plotText = plotText
        self.actor = actor
    }
    
    func toMovie() -> Movie {
        let M = Movie(
                id:     UUID(),
                title: self.title,
                director: self.director,
                releaseYear: self.releaseYear,
                poster: self.poster,
                still: self.still,
                genre: self.genre,
                keyword: self.keyword,
                plotText: self.plotText,
                actor: self.actor
               )
        return M
    }
}
