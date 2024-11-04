// Movie.swift
import Foundation

// 영화의 핵심 정보를 담은 구조체
struct Movie: Codable, Identifiable {
    let id: UUID
    let title: String
    let director: [String]
    let releaseDate: String?
    
    init(id: UUID = UUID(), title: String, director: [String], releaseDate: String? = nil) {
        self.id = id
        self.title = Movie.cleanStr(from: title)
        self.director = director.map{Movie.cleanStr(from: $0)}
        self.releaseDate = releaseDate
    }
    
    static func cleanStr(from str: String) -> String {
        var cleanedStr = str
        cleanedStr = cleanedStr.replacingOccurrences(of: " !HS ", with: "")
        cleanedStr = cleanedStr.replacingOccurrences(of: " !HE ", with: "")
        print(cleanedStr)
        return cleanedStr
    }
}

// 영화 상세 정보를 담은 구조체
struct MovieDetail: Decodable, Identifiable {
    let id: UUID  // Movie의 id를 사용
    let movie: Movie  // 핵심 정보를 담은 Movie 구조체
    let plotText: String?
    //let extra

    enum CodingKeys: String, CodingKey {
        case movie
        case plotText
        //case extra
    }

    enum MovieCodingKeys: String, CodingKey {
        case title
        case directors
        case prodYear
    }
    
    enum DirectorsCodingKeys: String, CodingKey {
        case director
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let movieContainer = try decoder.container(keyedBy: MovieCodingKeys.self)

        // movieContainer로부터 핵심 정보만 가져와 Movie 인스턴스를 초기화
        let title = try movieContainer.decode(String.self, forKey: .title)
        let directorsContainer = try movieContainer.nestedContainer(keyedBy: DirectorsCodingKeys.self, forKey: .directors)
        let directors = try directorsContainer.decode([Director].self, forKey: .director)
        let directorNames = directors.map {$0.directorNm}
        let releaseDate = try movieContainer.decodeIfPresent(String.self, forKey: .prodYear)
        
        // Movie의 id를 MovieDetail의 id로 설정
        let movie = Movie(title: title, director: directorNames, releaseDate: releaseDate)
        self.movie = movie
        self.id = movie.id  // Movie의 id를 MovieDetail의 id로 설정
        self.plotText = try container.decodeIfPresent(String.self, forKey: .plotText)
        //self.extra = try container.decodeIfPresent(String.self, forKey: .extra)
    }
}
                                                      
struct Director: Codable {
    let directorNm: String
}
