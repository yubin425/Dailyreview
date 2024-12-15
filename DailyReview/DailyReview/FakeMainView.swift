//
//  FakeMainView.swift
//  DailyReview
//
//  Created by 2022049898 on 11/6/24.
//
import SwiftData
import SwiftUI

struct FakeMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reviews: [Review]
    @State private var searchText = ""
    @State private var showSearchView = false
    

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {

                    VStack {
                        ZStack(alignment: .topTrailing) { // ZStack으로 뷰 겹치기, 오른쪽 상단에 정렬
                            PosterCarouselView(reviews: reviews)
                                .frame(height: 500)
                            
                            NavigationLink(destination: SearchView(Flag: "main")) {
                                Image(systemName: "magnifyingglass")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.red)

                                    .clipShape(Circle())
                                    .padding() // 검색 버튼의 위치 조정
                            }
                        }
                        VStack {
                            StatisticsView(reviews: reviews,amount: 2)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}
