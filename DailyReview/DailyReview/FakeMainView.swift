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
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var refreshID = UUID()

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {

                    VStack {
                        ZStack(alignment: .top) {
                            PosterCarouselView(reviews: reviews)
                                .frame(height: 500)
                            
                            HStack{
                                Image(isDarkMode ? "LogoDark" : "Logo")
                                    .resizable()
                                    .frame(width:87, height:45)
                                    .padding()
                                
                                Spacer()
                                
                                NavigationLink(destination: SearchView(Flag: "main")) {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.red)
                                        .padding() // 검색 버튼의 위치 조정
                                }
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
        .onChange(of: reviews) { _ in
            refreshID = UUID() // Trigger a view refresh when the reviews array changes.
        }
    }
}
