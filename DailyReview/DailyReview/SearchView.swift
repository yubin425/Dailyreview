// SearchView.swift
import SwiftUI

struct SearchView: View {
    var Flag: String
    @EnvironmentObject var wishListFolder: WishListFolder  // 환경 객체로 WishListFolder를 받음
    var wishlistName: String?
    @State private var isNavigating = false
    @StateObject private var viewModel = MovieSearchModel()
    @State private var query = ""
    @State private var filter = "영화"
    let filters = ["영화", "감독", "배우", "키워드"]
    
    
    var body: some View {
        NavigationView {
            VStack {
                // 검색 창
                HStack{
                    // 검색 기준
                    Picker("검색 기준", selection: $filter){
                        ForEach(filters, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: filter){ _ in
                        query = ""
                    }
                    
                    // 검색 Query
                    TextField("\(filter) 검색", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .submitLabel(.search)
                    
                    // 검색 버튼
                    Button(action: {
                        viewModel.fetchMovies(filter: filter, query: query)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                
                // 검색 결과
                List(viewModel.movies) { theMovie in
                    if Flag == "wishlist" {
                        Button(action: {
                            wishListFolder.addMovieToWishList(name: wishlistName!, movie:theMovie)
                        }){
                            MovieHStack(theMovie: theMovie)
                        }
                    }
                    else {
                        NavigationLink(destination: DetailView(movie: theMovie)){
                            MovieHStack(theMovie: theMovie)
                        }
                    }
                }
            }
            .navigationTitle("영화 검색")
        }
    }
}

struct MovieHStack: View {
    var theMovie: Movie
    
    var body: some View {
        HStack{
            // 포스터
            if let posterURL = theMovie.poster,
               let url = URL(string: posterURL){
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
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 75)
            }
            
            // 영화 정보
            VStack(alignment: .leading) {
                Text(theMovie.title)
                    .font(.headline)
                Text("감독: \(theMovie.director.prefix(3).joined(separator: ", "))")
                Text("개봉일: \(theMovie.releaseYear ?? "정보 없음")")
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(Flag : "main").environmentObject(WishListFolder())
    }
}
