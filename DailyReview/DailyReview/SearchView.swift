// SearchView.swift
import SwiftUI

struct SearchView: View {
    var Flag: String
    var wishList: WishListFolder?
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
                            .padding(.trailing, 20)
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(40)
                .padding(.horizontal)
                
                // 검색 결과
                List(viewModel.movies) { theMovie in
                    if Flag == "wishlist" {
                        Button(action: {
                            wishList!.addMovie(theMovie.toStorage())
                        }){
                            movieInstanceView(movie: theMovie)
                        }
                    }
                    else {
                        NavigationLink(destination: DetailView(movie: theMovie)){
                            movieInstanceView(movie: theMovie)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}

struct movieInstanceView: View{
    var movie: Movie

    var body: some View{
        HStack{
            AsyncImageView(_URL: movie.poster)
                .scaledToFit()
                .frame(width: 60, height: 90)
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.director.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("개봉일: \(movie.releaseYear ?? "정보 없음")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
