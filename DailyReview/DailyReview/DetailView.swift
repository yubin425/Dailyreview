// DetailView.swift
// DailyReview
//
// Created by Lee Hyun on 11/6/24.

import SwiftUI
import SwiftData

struct DetailView: View {
    var movie: Movie // 선택된 영화의 상세 정보
    var fromWishlist: Bool?
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [WishListFolder]
    @State private var selectWishlist = false
    @State private var isExpanded = false // 줄거리 더보기 토글
    
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                MovieStillView(stillURL: movie.still, geometry: geometry)
            }
            ScrollView {
                VStack(spacing: 16) {
                    MovieTitleView(movie: movie)
                    MovieDetailsView(
                        movie: movie,
                        fromWishlist: fromWishlist,
                        folders: folders,
                        modelContext: modelContext,
                        selectWishlist: $selectWishlist,
                        isExpanded: $isExpanded
                    )
                    Spacer()
                }
            }
        }
        .navigationTitle("영화 상세 정보")
    }
}

private struct MovieStillView: View {
    var stillURL: String?
    var geometry: GeometryProxy

    var body: some View {
        if let stillURL = stillURL, !stillURL.isEmpty {
            AsyncImageView(_URL: stillURL)
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: 300)
                .clipped()
        } else {
            LinearGradient(
                gradient: Gradient(colors: [Color.red,Color("BackgroundColor")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct MovieTitleView: View {
    var movie: Movie

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColor").opacity(0.0), Color("BackgroundColor")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .padding(.top, 200)

            Text(movie.title)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.leading)
                .padding(.leading, 16)
                .padding(.top, 220)
                .lineLimit(1)
        }
    }
}

private struct MovieDetailsView: View {
    var movie: Movie
    var fromWishlist: Bool?
    var folders: [WishListFolder]
    var modelContext: ModelContext
    @Binding var selectWishlist: Bool
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            WishlistAndReviewButtons(
                movie: movie,
                fromWishlist: fromWishlist,
                folders: folders,
                modelContext: modelContext,
                selectWishlist: $selectWishlist
            )

            MovieHeaderView(movie: movie)

            if let plot = movie.plotText, !plot.isEmpty {
                MoviePlotView(plot: plot, isExpanded: $isExpanded)
            }
            Spacer()
            Spacer()
            Spacer()
        }
        .background(Color("BackgroundColor"))
        .cornerRadius(16)
        .padding(.top, -50)
    }
}



private struct WishlistAndReviewButtons: View {
    var movie: Movie
    var fromWishlist: Bool?
    var folders: [WishListFolder]
    var modelContext: ModelContext
    @Binding var selectWishlist: Bool

    var body: some View {
        HStack {
            Spacer()

            NavigationLink(destination: ReviewView(movie: movie)) {
                Image(systemName: "doc.text")
                    .font(.headline)
            }
            .buttonStyle(PlainButtonStyle())

            if fromWishlist != true {
                Button(action: {
                    if folders.count > 1 {
                        selectWishlist = true
                    } else if folders.count == 1 {
                        folders.first!.addMovie(movie.toStorage())
                    } else {
                        let firstWLName = "wishlist"
                        modelContext.insert(WishListFolder(name: firstWLName))
                        folders.first!.addMovie(movie.toStorage())
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                }
                .buttonStyle(PlainButtonStyle())
                .confirmationDialog(
                    "Select WishList",
                    isPresented: $selectWishlist,
                    titleVisibility: .visible
                ) {
                    ForEach(folders, id: \.id) { folder in
                        Button(folder.name) {
                            folder.addMovie(movie.toStorage())
                        }
                    }
                }
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

private struct MovieHeaderView: View {
    var movie: Movie

    var body: some View {
        HStack(spacing: 16) {
            AsyncImageView(_URL: movie.poster)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .cornerRadius(8)

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                    .multilineTextAlignment(.leading)

                Text("\(movie.director.first ?? "Unknown"), \(movie.releaseYear ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(tags)
                    .font(.subheadline)
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal)
        .padding(.horizontal)
    }

    private var tags: String {
        let genreTags = movie.genre.prefix(2).map { "#\($0)" }
        let keywordTags = movie.keyword.prefix(1).map { "#\($0)" }
        return (genreTags + keywordTags).joined(separator: " ")
    }
}

private struct MoviePlotView: View {
    var plot: String
    @Binding var isExpanded: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(plot.splitWord())
                .multilineTextAlignment(.leading)
                .lineLimit(isExpanded ? nil : 3)
                .font(.body)
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if !isExpanded {
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundColor").opacity(0), .white]),
                    startPoint: .center,
                    endPoint: .trailing
                )
                .frame(height: 20)
                .allowsHitTesting(false)

                HStack {
                    Spacer()
                    Button(action: { isExpanded.toggle() }) {
                        Text("...더보기")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 8)
                }
            }
        }
        .padding(.horizontal)
    }
}
