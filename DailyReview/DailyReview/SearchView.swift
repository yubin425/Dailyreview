// SearchView.swift
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = MovieSearchModel()
    @State private var searchText = "어벤져스"
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("영화를 검색하세요...", text: $searchText, onCommit: {
                    viewModel.fetchMovies(for: searchText)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                List(viewModel.movies) { movieDetail in
                    VStack(alignment: .leading) {
                        Text(movieDetail.movie.title)
                            .font(.headline)
                        if let plot = movieDetail.plotText {
                            Text(plot)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Text("감독: \(movieDetail.movie.director.prefix(3).joined(separator: ", "))")
                        Text("개봉일: \(movieDetail.movie.releaseDate ?? "정보 없음")")
                    }
                }
            }
            .navigationTitle("KMDb 영화 검색")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
