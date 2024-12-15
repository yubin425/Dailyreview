// MovieSearchModel.swift
import Foundation
import Combine

class MovieSearchModel: ObservableObject {
    @Published var movies = [Movie]()
    private var cancellable: AnyCancellable?
    private let apiKey = "XC592QN1I4K1F8OAM2T0"
    private let filterDict:[String:String] = [
        "영화":"title",
        "감독":"director",
        "배우":"actor",
        "키워드":"keyword"
    ]

    func fetchMovies(filter: String, query: String) {
        let urlString = "https://api.koreafilm.or.kr/openapi-data2/wisenut/search_api/search_json2.jsp?collection=kmdb_new2&\(filterDict[filter]!)=\(query)&ServiceKey=\(apiKey)&detail=Y"
        
        guard let url = URL(string: urlString) else { return }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching movies: \(error)")
                    self.movies = []
                }
            }, receiveValue: { [weak self] response in
                // 응답 데이터를 기반으로 movies 배열을 업데이트
                self?.movies = response.Data.flatMap { $0.Result }
            })
    }
}

// API 응답 모델을 정의한 구조체
struct MovieResponse: Decodable {
    let Data: [MovieData]
}

struct MovieData: Decodable {
    let Result: [Movie]
}
