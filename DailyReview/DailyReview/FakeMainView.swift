//
//  FakeMainView.swift
//  DailyReview
//
//  Created by 2022049898 on 11/6/24.
//

import SwiftUI

struct FakeMainView: View {
    @State private var searchText = ""
    @State private var showSearchView = false
    let posters = ["poster1", "poster2", "poster3", "poster4", "poster5"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Color.white
                        .frame(height: 100)

                    Color.black
                        .frame(height: 630)

                    Color.white
                        .frame(height: 30)
                }

                VStack {
                    ZStack(alignment: .topTrailing) { // ZStack으로 뷰 겹치기, 오른쪽 상단에 정렬
                            PosterCarouselView(posters: posters)
                                .frame(height: 520)

                            NavigationLink(destination: SearchView(Flag: "main")) {
                                Image(systemName: "magnifyingglass")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .padding() // 검색 버튼의 위치 조정
                            }
                        }

                    VStack(spacing: 10) {
                        NotificationBlock(message: "통계\n1")
                        NotificationBlock(message: "통계\n2")
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
    }
}
