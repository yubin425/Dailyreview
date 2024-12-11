import SwiftUI

struct SearchView: View {
    var Flag: String
    var wishList: WishListFolder?
    @State private var isNavigating = false
    @StateObject private var viewModel = MovieSearchModel()
    @State private var query = ""
    @State private var filter = "영화"
    let filters = ["영화", "감독", "배우", "키워드"]
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                // 검색 창
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGray5))
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(30)
                            
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("\(filter) 검색", text: $query)
                                .focused($isTextFieldFocused)
                                .submitLabel(.search)
                                .onSubmit {
                                    viewModel.fetchMovies(filter: filter, query: query)
                                }
                            
                            if !query.isEmpty {
                                Button(action: {
                                    query = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .frame(height: 40)
                    
                    // 필터 버튼
                    Menu {
                        ForEach(filters, id: \.self) { filterOption in
                            Button(action: {
                                filter = filterOption
                                query = "" // 필터 변경 시 검색 텍스트 초기화
                            }) {
                                Text(filterOption)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // 검색 결과
                if viewModel.movies.isEmpty {
                    Spacer()
                    Text(query.isEmpty ? "검색어를 입력해주세요." : "검색 결과가 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(viewModel.movies) { theMovie in
                        if Flag == "wishlist" {
                            Button(action: {
                                wishList!.addMovie(theMovie.toStorage())
                            }) {
                                movieInstanceView(movie: theMovie)
                            }
                        } else {
                            NavigationLink(destination: DetailView(movie: theMovie)) {
                                movieInstanceView(movie: theMovie)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
    }
}

struct movieInstanceView: View {
    var movie: Movie

    var body: some View {
        HStack {
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
