import SwiftUI
import SwiftData

var sim = false

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
                                NavigationLink(destination: WishListView(wishList: folder)) {
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
            modelContext.delete(folderToDelete)
        }
    }
}

struct WishListFolderAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var wishlistTitle: String = ""
    @Environment(\.modelContext) private var modelContext
    @State private var wishlist: WishListFolder = WishListFolder(name:"Empty")
    @State private var wl: CodableWL = CodableWL(wl:WishListFolder(name: "Empty"))
    @State private var showDocumentPicker = false
    @State private var loadError: String? = nil
    @State private var isLoaded = "불러오기"

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
                    wishlist.rename(wishlistTitle)
                    modelContext.insert(wishlist)
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
                
                Button(action: {
                    // 시뮬레이터일 때
                    if sim {
                        if let wl = loadJsonFile(){
                            isLoaded = "불러오기 완료"
                            wishlist = wl
                        }
                    }
                    else{
                        showDocumentPicker = true
                    }
                }) {
                    Text(isLoaded)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 160, height: 40)
                        .background(Color.red)
                        .cornerRadius(40)
                }
                .padding(.horizontal)
                .disabled(isLoaded == "불러오기 완료")
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPickerView(
                        wl: wl,
                        wishlist: $wishlist,
                        isLoaded: $isLoaded,
                        mode: .importFile,
                        onError: { error in
                            loadError = error
                        }
                    )
                }
            }
        }
    }
}

struct WishListView: View {
    @State var wishList: WishListFolder
    @State private var wl: CodableWL = CodableWL(wl:WishListFolder(name: "Empty"))
    @State private var delete = false
    @State private var newTitle: String = "" // 새로운 제목을 입력받을 변수
    @State private var showAlert = false // 알림 창을 표시하는 변수
    @State private var showDocumentPicker = false
    @State private var loadError: String? = nil
    @State private var isLoaded: String = ""
    
    var body: some View {
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
                        Button("공유"){
                            if sim {
                                wl = CodableWL(wl: wishList)
                                createJsonFile(wishlist: wl)
                            }
                            else{
                                wl = CodableWL(wl: wishList)
                                showDocumentPicker = true
                            }
                        }
                        .sheet(isPresented: $showDocumentPicker) {
                            DocumentPickerView(
                                wl: wl,
                                wishlist: $wishList,
                                isLoaded: $isLoaded,
                                mode: .export,
                                onError: { error in
                                    loadError = error
                                }
                            )
                        }
                        
                        Button("이름 변경하기") {
                            // 버튼을 눌렀을 때 알림 창을 띄운다
                            showAlert = true
                        }
                        .padding()
                        .sheet(isPresented: $showAlert) {
                            VStack {
                                Text("새로운 제목을 입력하세요")
                                    .font(.headline)
                                    .padding()

                                // 새로운 제목을 입력받을 TextField
                                TextField("새로운 제목을 입력하세요", text: $newTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()

                                // 제목을 수정하는 버튼
                                Button("수정하기") {
                                    if !newTitle.isEmpty {
                                        // 새로운 제목으로 업데이트
                                        wishList.rename(newTitle)
                                        showAlert = false // Sheet 닫기
                                    }
                                }
                                .padding()

                                // 취소 버튼
                                Button("취소") {
                                    showAlert = false // Sheet 닫기
                                }
                                .padding()
                            }
                            .padding()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }

    private func deleteMovie(at offsets: IndexSet) {
        for index in offsets {
            let movie = wishList.movies[index]
            wishList.removeMovie(movie)
        }
    }
}
