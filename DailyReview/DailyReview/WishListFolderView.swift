import SwiftUI
import SwiftData

struct WishListFolderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [WishListFolder]
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // 추가, 삭제 버튼 + 검색
                VStack {
                    HStack(spacing: 15) {
                        // 새로운 위시리스트 추가 버튼
                        NavigationLink(destination: WishListFolderAddView()) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.red)
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
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 20)
                            }
                            .padding(.trailing),
                            alignment: .trailing
                        )
                        .submitLabel(.search)
                }
                Spacer()

                // 목록
                VStack {
                    if folders.isEmpty {
                        Text("위시리스트가 없습니다.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(folders.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }) { folder in
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
                        .scrollContentBackground(.hidden) // 기본 배경 숨기고
                        .background(Color.gray.opacity(0.1)) // 원하는 배경색 적용
                    }
                }
                Spacer()
            }
        }
    }

    private func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            let folderToDelete = folders[index]
            modelContext.delete(folderToDelete)
        }
    }
}

struct WishListFolderAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var wishlistTitle: String = ""
    @Environment(\.modelContext) private var modelContext

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
                }) {
                    Text("등록")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 120, height: 40)
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
                            NavigationLink(destination: DetailView(movie: movie.toMovie(), fromWishlist: true)) {
                                movieInstanceView(movie: movie.toMovie())
                            }
                        }
                        .onDelete(perform: deleteMovie)
                    }
                    .scrollContentBackground(.hidden) // 기본 배경 숨기고
                    .background(Color.gray.opacity(0.1)) // 원하는 배경색 적용
                }
            }
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(wishList.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        NavigationLink(destination: SearchView(Flag: "wishlist", wishList: wishList)) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.red)
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
