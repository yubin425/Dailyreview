import SwiftUI
import SwiftData

struct WishListFolderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [WishListFolder]
    @State private var searchText = ""
    
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
                    if folders.isEmpty {
                        Text("위시리스트가 없습니다.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // 위시리스트 목록
                        List {
                            ForEach(folders.filter{ searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)}) { folder in
                                NavigationLink(destination: WishListView(wishListFolder: folder)) {
                                    HStack {
                                        AsyncImageView(_URL: folder.getPoster())
                                            .scaledToFit()
                                            .frame(width: 60, height: 90)
                                        Text(folder.name)
                                    }
                                }
                            }
                            .onDelete(perform: deleteFolder)
                        }
                    }
                }
                Spacer()
            }
        }
    }
    private func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            let folderToDelete = folders[index]
            modelContext.delete(folderToDelete) // SwiftData에서 삭제
        }
    }
}


struct WishListFolderAddView: View {
    @Environment(\.presentationMode) var presentationMode // 네비게이션 제어용
    @State private var wishlistTitle: String = ""
    @Environment(\.modelContext) private var modelContext // SwiftData 컨텍스트

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
                    let newFolder = WishListFolder(name: wishlistTitle)
                    modelContext.insert(newFolder)
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save new folder: \(error)")
                    }
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
    var wishListFolder: WishListFolder
    @State private var delete = false
    
    var body: some View {
        let wishList = wishListFolder
        NavigationView {
            VStack {
                if wishList.movies.isEmpty {
                    Text("위시리스트가 비어 있습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(wishList.movies) { movie in
                            NavigationLink(destination: DetailView(movie:movie.toMovie(), fromWishlist: true)){
                                movieInstanceView(movie:movie.toMovie())
                            }
                        }
                        .onDelete(perform: deleteMovie)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline) // 타이틀을 줄여서 표시

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(wishList.name) // 네비게이션 타이틀을 왼쪽에 위치
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack (spacing:10){
                        // 새로운 위시리스트 추가 버튼
                        NavigationLink(destination: SearchView(Flag: "wishlist",wishList: wishList))
                        {
                            Text("추가")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    private func deleteMovie(at offsets: IndexSet) {
        for index in offsets {
            let movie = wishListFolder.movies[index]
            wishListFolder.removeMovie(movie)
        }
    }
}
