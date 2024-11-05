// SearchView.swift
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = MovieSearchModel()
    @State private var query = ""
    @State private var filter = "영화"
    let filters = ["영화", "감독", "배우", "키워드"]
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    Picker("검색 자료", selection: $filter){
                        ForEach(filters, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: filter){
                        query = ""
                    }
                    
                    TextField("\(filter) 검색", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .submitLabel(.search)
                    
                    Button(action: {
                        viewModel.fetchMovies(filter: filter, query: query)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                
                List(viewModel.movies) { movieDetail in
                    HStack{
                        if let posterURL = movieDetail.movie.poster,
                           let url = URL(string: posterURL.replacingOccurrences(of: "http://", with: "https://")){
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 75)
                                case .failure:
                                    Image(systemName: "photo")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else{
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 75)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(movieDetail.movie.title)
                                .font(.headline)
                            Text("감독: \(movieDetail.movie.director.prefix(3).joined(separator: ", "))")
                            Text("개봉일: \(movieDetail.movie.releaseDate ?? "정보 없음")")
                        }
                    }
                    .onTapGesture {
                        print(movieDetail.plotText!)
                    }
                }
            }
            .navigationTitle("영화 검색")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
