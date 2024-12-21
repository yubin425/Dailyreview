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
                        
                        TextField("Search Wishlist", text: $searchText)
                            .padding(10) // 내부 여백 설정
                            .padding(.leading, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemGray5)) // 배경 색상
                            )
                            .overlay(
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 10) // 아이콘의 여백
                                    Spacer() // 텍스트 입력 필드와 아이콘 사이의 공간
                                }
                            )
                            .cornerRadius(30) // 전체 모서리 반경
                            .padding(.horizontal) // 외부 여백
                            .submitLabel(.search) // 키보드 제출 버튼 스타일
                            .onSubmit {
                                // 검색 동작 수행
                                print("\(searchText)")
                            }
                        
                        // 새로운 위시리스트 추가 버튼
                        NavigationLink(destination: WishListFolderAddView()) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                        

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
                            ForEach(folders
                                .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
                                .sorted { $0.order < $1.order }) { folder in                                NavigationLink(destination: WishListView(wishList: folder)) {
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
                        .toolbar{
                            EditButton()
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
    @State private var isLoaded = "불러오기"
    @State private var isPickerPresented = false
    @Query private var folders: [WishListFolder]
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("위시리스트 제목 입력", text: $wishlistTitle)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(40)
                    .padding(.horizontal)
                    .textFieldStyle(PlainTextFieldStyle())
                HStack{
                    Button(action: {
                        let lastFolder = folders.sorted { $0.order < $1.order }.last
                        let newOrder = (lastFolder?.order ?? -1) + 1
                        wishlist.reorder(newOrder)
                        wishlist.rename(wishlistTitle)
                        modelContext.insert(wishlist)
                        do {
                            try modelContext.save() // Core Data에 변경 사항 저장
                        } catch {
                            print("Failed to save the updated order: \(error.localizedDescription)")
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
                    .disabled(wishlistTitle.isEmpty)
                                    
                    Button(action: {
                        isPickerPresented.toggle()
                    }) {
                        Text(isLoaded)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 160, height: 40)
                            .background(Color.red)
                            .cornerRadius(40)
                    }
                    .padding()
                    .sheet(isPresented: $isPickerPresented) {
                        DocumentPicker(selectedFileContent: $wishlist, isLoaded: $isLoaded)
                        
                    }
                    .disabled(isLoaded == "불러오기 완료")
                }
            }
        }
    }
}

struct WishListView: View {
    @State var wishList: WishListFolder
    @State private var delete = false
    @State private var newTitle: String = "" // 새로운 제목을 입력받을 변수
    @State private var showAlert = false // 알림 창을 표시하는 변수
    @State private var showDocumentPicker = false
    
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
                        .onMove(perform: moveMovie)     // Move action
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
                        .padding()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        NavigationLink(destination: SearchView(Flag: "wishlist", wishList: wishList)) {
                            Image(systemName: "plus") // 동그란 + 버튼
                                   .foregroundColor(.white)
                                   .frame(width: 30, height: 30)
                                   .background(Color.red)
                                   .clipShape(Circle())
                        }
                        // 공유 버튼
                        Button(action: {
                            shareContent(CodableWL(wl: wishList))
                        }) {
                            Label("공유", systemImage: "square.and.arrow.up") // 공유 아이콘
                                .foregroundColor(.primary)
                        }

                        // 이름 변경하기 버튼
                        Button(action: {
                            showAlert = true
                        }) {
                            Label("이름 변경하기", systemImage: "pencil") // 수정 아이콘
                                .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $showAlert) {
                            VStack {
                                Text("위시리스트 제목 수정")
                                    .padding()
                                    .font(.system(size:24))

                                // 새로운 제목을 입력받을 TextField
                                TextField("새로운 제목을 입력하세요", text: $newTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                
                                HStack{
                                    // 제목을 수정하는 버튼
                                    Button("수정하기") {
                                        if !newTitle.isEmpty {
                                            // 새로운 제목으로 업데이트
                                            wishList.rename(newTitle)
                                            showAlert = false // Sheet 닫기
                                        }
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 40)
                                    .background(Color.red)
                                    .cornerRadius(40)
                                    .foregroundColor(.red)
                                    .padding()

                                    // 취소 버튼
                                    Button("취소") {
                                        showAlert = false // Sheet 닫기
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 40)
                                    .background(Color.red)
                                    .cornerRadius(40)
                                    .foregroundColor(.red)
                                    .padding()
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
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
    
    private func moveMovie(from source: IndexSet, to destination: Int) {
        wishList.movies.move(fromOffsets: source, toOffset: destination)
    }
}
