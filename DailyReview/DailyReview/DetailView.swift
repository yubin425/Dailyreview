//
//  DetailView.swift
//  DailyReview
//
//  Created by Lee Hyun on 11/6/24.
//


import SwiftUI
import SwiftData

struct DetailView: View {
    var movie: Movie // 선택된 영화의 상세 정보
    var fromWishlist: Bool?
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [WishListFolder]
    @State private var selectWishlist = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                AsyncImageView(_URL: movie.still)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                // 영화 제목
                
                // 감독 정보
                Text("감독: \(movie.director.prefix(3).joined(separator: ", "))")
                    .font(.subheadline)
                
                // 개봉일 정보
                Text("개봉일: \(movie.releaseYear ?? "정보 없음")")
                    .font(.subheadline)
                    .padding(.bottom, 10)
                
                // 줄거리
                Text("줄거리")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.vertical, 5)
                
                Text(movie.plotText ?? "줄거리 정보 없음")
                    .font(.body)
                    .lineLimit(nil)
            }
            .padding()
            HStack {
                NavigationLink(destination: ReviewView(movie: movie)) {
                    Text("리뷰 추가")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                if fromWishlist != true{
                    Button(action:{
                        if folders.count > 1{
                            selectWishlist = true
                        }
                        else if folders.count == 1{
                            let ms = movie.toStorage()
                            modelContext.insert(ms)
                            folders.first!.addMovie(ms)
                        }
                        else{
                            let firstWLName = "Wishlist"
                            let firstWishList = WishListFolder(name:firstWLName)
                            let ms = movie.toStorage()
                            modelContext.insert(ms)
                            firstWishList.addMovie(ms)
                            modelContext.insert(firstWishList)
                        }
                    })
                    {
                        Text("위시리스트 추가")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .actionSheet(isPresented: $selectWishlist){
                        ActionSheet(title: Text("Select WishList"), message: nil, buttons:folders.map {folder in
                            ActionSheet.Button.default(Text(folder.name)){
                                let ms = movie.toStorage()
                                modelContext.insert(ms)
                                folder.addMovie(ms)
                            }
                        })
                    }
                }
            }
            .padding(.top, 20)
            Spacer()
        }
        .navigationTitle("영화 상세 정보")
    }
}
