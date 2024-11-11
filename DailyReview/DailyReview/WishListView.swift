//
//  WishlistView.swift
//  DailyReview
//
//  Created by Lee Hyun on 11/6/24.
//
import SwiftUI

struct WishlistView: View {
    let movie: Movie  // DetailView에서 전달받은 영화 정보

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("위시리스트 추가 - \(movie.title)")
                .font(.title)
                .padding(.bottom, 5)

            Button(action: {
                // 위시리스트에 영화 추가 로직 추가
                print("위시리스트에 \(movie.title) 추가")
            }) {
                Text("위시리스트에 추가")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("위시리스트 추가")
    }
}
