// Movie.swift
import Foundation

// 영화의 핵심 정보를 담은 구조체
struct Movie: Codable, Identifiable {
    let id: UUID
    let title: String
    let director: [String]
    let releaseDate: String?
    let poster: String?
    
    init(id: UUID = UUID(), title: String, director: [String], releaseDate: String? = nil, poster:String? = nil) {
        self.id = id
        self.title = Movie.cleanStr(from: title)
        self.director = director.map{Movie.cleanStr(from: $0)}
        self.releaseDate = releaseDate
        self.poster = Movie.extractFirstPoster(from:poster)
    }
    
    static func cleanStr(from str: String) -> String {
        var cleanedStr = str
        cleanedStr = cleanedStr.replacingOccurrences(of: " !HS ", with: "")
        cleanedStr = cleanedStr.replacingOccurrences(of: " !HE ", with: "")
        return cleanedStr
    }
    
    static func extractFirstPoster(from poster: String?) -> String? {
        return poster?.components(separatedBy: "|").first
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
        case plotText = "plots"
        //case extra
    }

    // api가 주는 key
    enum MovieCodingKeys: String, CodingKey {
        case title
        case directors
        case prodYear
        case posters
    }
    
    enum DirectorsCodingKeys: String, CodingKey {
        case director
    }
    
    enum PlotCodingKeys: String, CodingKey {
        case plot
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
        let poster = try movieContainer.decodeIfPresent(    String.self, forKey: .posters)
        
        let plotContainer = try container.nestedContainer(keyedBy: PlotCodingKeys.self, forKey: .plotText)
        let plot = try plotContainer.decode([Plot].self, forKey: .plot)
        // Movie의 id를 MovieDetail의 id로 설정
        let movie = Movie(title: title, director: directorNames, releaseDate: releaseDate, poster: poster)
        self.movie = movie
        self.id = movie.id  // Movie의 id를 MovieDetail의 id로 설정
        self.plotText = plot.first?.plotText
        //self.extra = try container.decodeIfPresent(String.self, forKey: .extra)
    }
}
                                                      
struct Director: Codable {
    let directorNm: String
}

struct Plot: Codable {
    let plotLang: String
    let plotText: String
}

struct Plots: Codable {
    let plot: [Plot]
}
