import SwiftUI

struct SearchView: View {
    var Flag: String
    var wishList: WishListFolder?
    @Environment(\.modelContext) private var modelContext
    @State private var isNavigating = false
    @StateObject private var viewModel = MovieSearchModel()
    @State private var query = ""
    @State private var filter = "영화"
    let filters = ["영화", "감독", "배우", "키워드"]
    @FocusState private var isTextFieldFocused: Bool
    @State private var isShowingCustomMovieInput = false
    @State private var customMovie: Movie?

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

                    Button("직접 영화 입력하기") {
                        isShowingCustomMovieInput = true
                    }
                    .padding()
                    .sheet(isPresented: $isShowingCustomMovieInput) {
                        CustomMovieInputView { movie in
                            DispatchQueue.main.async {
                                self.customMovie = movie
                                self.isNavigating = true
                            }
                        }
                    }

                    Spacer()
                } else {
                    List(viewModel.movies) { theMovie in
                        if Flag == "wishlist" {
                            Button(action: {
                                let ms = theMovie.toStorage()
                                modelContext.insert(ms)
                                wishList!.addMovie(ms)
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

                // 네비게이션 상태
                NavigationLink(
                    destination: customMovie.map { ReviewView(movie: $0) },
                    isActive: $isNavigating,
                    label: {
                        EmptyView()
                    }
                )
            }
            .onChange(of: isNavigating) { newValue in
                if newValue, customMovie == nil {
                    isNavigating = false
                }
            }
        }
    }
}

struct CustomMovieInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var director = ""
    @State private var releaseYear = ""
    @State private var genre = ""
    @State private var keyword = ""
    @State private var plotText = ""
    @State private var actor = ""
    @State private var errorMessage: String? = nil
    var onComplete: (Movie) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Movie Information")) {
                    TextField("제목", text: $title)
                    TextField("감독", text: $director)
                    TextField("개봉연도", text: $releaseYear)
                        .keyboardType(.numberPad)
                    TextField("장르(,로 구분)", text: $genre)
                    TextField("키워드(,로 구분)", text: $keyword)
                    TextField("줄거리", text: $plotText)
                    TextField("배우(,로 구분)", text: $actor)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("리뷰 쓰기") {
                    if validateInput() {
                        let newMovie = Movie(
                            id: UUID(),
                            title: title,
                            director: director.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            releaseYear: releaseYear.isEmpty ? nil : releaseYear,
                            poster: nil,
                            still: nil,
                            genre: genre.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            keyword: keyword.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            plotText: plotText.isEmpty ? nil : plotText,
                            actor: actor.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        )
                        onComplete(newMovie)
                        dismiss()
                    }
                }
                .disabled(!validateInput())
            }
            .navigationTitle("Custom Movie")
        }
    }

    private func validateInput() -> Bool {
        if title.isEmpty {
            errorMessage = "Title is required."
            return false
        }
        if director.isEmpty {
            errorMessage = "Director(s) is required."
            return false
        }
        if !releaseYear.isEmpty, Int(releaseYear) == nil {
            errorMessage = "Release Year must be a valid number."
            return false
        }
        errorMessage = nil
        return true
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
