//
//  DetailView.swift
//  DailyReview
//
//  Created by Lee Hyun on 11/6/24.
//


import SwiftUI

struct DetailView: View {
    var movie: Movie // 선택된 영화의 상세 정보
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // 포스터 이미지
                if let posterURL = movie.poster,
                    let url = URL(string: posterURL.replacingOccurrences(of: "http://", with: "https://")){
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                }
                if let stillURL = movie.still,
                        let url = URL(string: stillURL.replacingOccurrences(of: "http://", with: "https://")){
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                            case .failure:
                                Image(systemName: "photo")
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                    }

                // 영화 제목
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
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
                NavigationLink(destination: WishlistView(movie: movie)) {
                    Text("리뷰 추가")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: WishlistView(movie: movie)) {
                    Text("위시리스트 추가")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 20)
            Spacer()
        }
        .navigationTitle("영화 상세 정보")
    }
}
