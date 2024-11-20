// Movie.swift
import Foundation

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
    
    init(id: UUID = UUID(), title: String, director: [String], releaseYear: String? = nil, poster: String? = nil, still: String? = nil, genre: [String], keyword: [String], plotText: String? = nil) {
        self.id = id
        self.title = Movie.cleanStr(from: title)
        self.director = director.map { Movie.cleanStr(from: $0) }
        self.releaseYear = releaseYear
        self.poster = Movie.extractFirst(from: poster)?.replacingOccurrences(of: "http://", with: "https://")
        self.still = Movie.extractFirst(from: still)?.replacingOccurrences(of: "http://", with: "https://")
        self.genre = genre
        self.keyword = keyword
        self.plotText = plotText
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
        self.init(title: title, director: director, releaseYear: releaseYear, poster: poster, still: still, genre: genre, keyword: keyword, plotText: plotText)
    }
}
                                                      
struct Director: Codable {
    let directorNm: String
}

struct Plot: Codable {
    let plotLang: String
    let plotText: String
}
