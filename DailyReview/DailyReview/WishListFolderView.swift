import SwiftUI

struct WishListFolderView: View {
    @EnvironmentObject var wishListFolder: WishListFolder
    @State private var searchText = ""
    @State private var delete = false
    
    var body: some View {
        NavigationStack{
            VStack{
                // 추가, 삭제 버튼 + 검색
                VStack {
                    HStack (spacing:15){
                        // 새로운 위시리스트 추가 버튼
                        NavigationLink(destination: WishListFolderAddView())
                        {
                            Text("추가")
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 50, height: 50)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            delete.toggle()
                        }) {
                            Text(delete ? "취소" : "제거")
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 50, height: 50)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    TextField("Search Wishlist", text: $searchText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(40)
                        .padding(.horizontal)
                        .textFieldStyle(PlainTextFieldStyle())
                        .overlay(
                            HStack {
                                Spacer()  // TextField의 오른쪽 끝에 아이콘을 위치시키기 위해 Spacer 사용
                                Image(systemName: "magnifyingglass")  // 돋보기 아이콘
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 20)  // 오른쪽 여백
                            }
                            .padding(.trailing), alignment: .trailing // 오른쪽 끝에 배치
                        )
                        .submitLabel(.search)
                }
                Spacer()

                // 목록
                VStack{
                    // 위시리스트가 없다면 안내 메시지
                    if wishListFolder.wishLists.isEmpty {
                        Text("위시리스트가 없습니다.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // 위시리스트 목록
                        List {
                            ForEach(wishListFolder.wishLists.keys.sorted().filter{ $0.lowercased().contains(searchText.lowercased()) || searchText == ""}, id: \.self) { name in
                                if delete {
                                    Button(action: {
                                        wishListFolder.deleteWishList(name:name)
                                    }) {
                                        HStack {
                                            if let posterUrl = wishListFolder.getPoster(name: name), let url = URL(string: posterUrl) {
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
                                                } else {
                                                    Image(systemName: "film.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 90)
                                                        .foregroundColor(.blue)
                                                }
                                            Text(name)
                                                .foregroundColor(Color.black)
                                            Spacer()
                                            Image(systemName: "trash").foregroundColor(.red)
                                                .frame(alignment: .trailing)
                                        }
                                    }
                                }
                                else {
                                    NavigationLink(destination: WishListView(name: name).environmentObject(wishListFolder)) {
                                        HStack {
                                            if let posterUrl = wishListFolder.getPoster(name: name), let url = URL(string: posterUrl) {
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
                                            } else {
                                                Image(systemName: "film.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60, height: 90)
                                                    .foregroundColor(.blue)
                                            }
                                            Text(name)
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .onAppear(perform: {wishListFolder.addNewWishList(name: "as")})
    }
}


struct WishListFolderAddView: View {
    @EnvironmentObject var wishListFolder: WishListFolder
    @Environment(\.presentationMode) var presentationMode // 네비게이션 제어용
    @State private var wishlistTitle: String = ""


    var body: some View {
        NavigationView {
            VStack {
                TextField("위시리스트 제목 입력", text: $wishlistTitle)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(40)
                    .padding(.horizontal)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Button(action: {
                    wishListFolder.addNewWishList(name: wishlistTitle)
                    presentationMode.wrappedValue.dismiss()
                })
                {
                    Text("등록")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 120, height:40)
                        .background(Color.red)
                        .cornerRadius(40)
                }
                .padding(.horizontal)
                .disabled(wishlistTitle.isEmpty)
            }
        }
    }
}


struct WishListView: View {
    @EnvironmentObject var wishListFolder: WishListFolder  // 환경 객체로 WishListFolder를 받음
    var name:String
    @State private var delete = false
    
    var body: some View {
        let wishList = wishListFolder.wishLists[name]!
        NavigationView {
            VStack {
                if wishList.isEmpty {
                    Text("위시리스트가 비어 있습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(wishList) { movie in
                            if delete {
                                Button(action: {
                                    wishListFolder.removeMovieToWishList(name: name, movie: movie)
                                }) {
                                    HStack {
                                        movieInstance(movie:movie, name:name)
                                        Spacer()
                                        Image(systemName: "trash").foregroundColor(.red)
                                            .frame(alignment: .trailing)
                                    }
                                }
                            }
                            else {
                                NavigationLink(destination: DetailView(movie:movie, fromWishlist: true)){
                                    movieInstance(movie:movie, name:name)
                                }
                            }
                            
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline) // 타이틀을 줄여서 표시

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(name) // 네비게이션 타이틀을 왼쪽에 위치
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack (spacing:10){
                        // 새로운 위시리스트 추가 버튼
                        NavigationLink(destination: SearchView(Flag: "wishlist",wishlistName: name).environmentObject(wishListFolder))
                        {
                            Text("추가")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            delete.toggle()
                        }) {
                            Text(delete ? "취소" : "제거")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}

struct movieInstance: View{
    var movie: Movie
    var name: String
    @EnvironmentObject var wishListFolder: WishListFolder

    var body: some View{
        HStack{
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
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 75)
            }
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.director.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}


struct WLFView_Previews: PreviewProvider {
    static var previews: some View {
        WishListFolderView().environmentObject(WishListFolder())
    }
}
