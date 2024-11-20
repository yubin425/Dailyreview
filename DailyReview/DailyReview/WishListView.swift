import SwiftUI

struct WishListView: View {
    @EnvironmentObject var wishListFolder: WishListFolder  // 환경 객체로 WishListFolder를 받음
    var name:String
    
    var body: some View {
        var wishList = wishListFolder.wishLists[name]!
        NavigationView {
            VStack {
                if wishList.isEmpty {
                    Text("위시리스트가 비어 있습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(wishList) { movie in
                            HStack {
                                if let posterUrl = movie.poster, let url = URL(string: posterUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable().scaledToFit().frame(width: 60, height: 90)
                                        case .failure:
                                            Image(systemName: "film").resizable().scaledToFit().frame(width: 60, height: 90)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .font(.headline)
                                    Text(movie.director.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    wishListFolder.removeMovieToWishList(name: name, movie: movie)
                                }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("위시리스트") // 네비게이션 타이틀 설정
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SearchView(Flag: "wishlist", wishlistName:name)) {
                        // "+" 버튼
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
