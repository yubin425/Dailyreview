import SwiftUI

struct WishListFolderView: View {
    @EnvironmentObject var wishListFolder: WishListFolder
    
    var body: some View {
        NavigationView{
            VStack {
                // 위시리스트가 없다면 안내 메시지
                if wishListFolder.wishLists.isEmpty {
                    Text("위시리스트가 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // 위시리스트 목록
                    List {
                        ForEach(wishListFolder.wishLists.keys.sorted(), id: \.self) { name in
                            NavigationLink(destination: WishListView(name: name).environmentObject(wishListFolder)) {
                                Text("위시리스트 \(name)")
                            }
                        }
                    }
                }
                AddWishListButton()
            }
            .navigationTitle("위시리스트 폴더")
        }
    }
}

struct AddWishListButton: View {
    @EnvironmentObject var wishListFolder: WishListFolder  // 환경 객체로 WishListFolder를 받음
    @State private var newWishListName: String = "" // 사용자 입력을 저장할 변수

    var body: some View {
        VStack {
            // 이름을 입력할 수 있는 텍스트 필드
            TextField("새로운 위시리스트 이름", text: $newWishListName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 새로운 위시리스트 추가 버튼
            Button(action: {
                // 이름이 비어 있지 않으면 새로운 위시리스트를 추가
                if !newWishListName.isEmpty {
                    wishListFolder.addNewWishList(name: newWishListName)
                    newWishListName = ""
                }
            }) {
                Text("새로운 위시리스트 추가")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}

struct WLFView_Previews: PreviewProvider {
    static var previews: some View {
        WishListFolderView().environmentObject(WishListFolder())
    }
}
