//
//  ContentView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/28/24.
//

import SwiftUI
import UIKit


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .edgesIgnoringSafeArea(.all)
    }
}



struct SearchResultsView: View {
    var body: some View {
        VStack {
            Text("This is the Search Results view")
                .padding()
            Spacer()
        }
        .navigationTitle("Search Results")
    }
}

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FakeMainView() // Show FakeMainView in the search tab
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("SEARCH")
                    }
                }
                .tag(0)

            ReviewView()
                .tabItem {
                    VStack {
                        Image(systemName: "pencil")
                        Text("REVIEW")
                    }
                }
                .tag(1)

            WishListView()
                .tabItem {
                    VStack {
                        Image(systemName: "bookmark")
                        Text("WISHLIST")
                    }
                }
                .tag(2)

            MyPageView()
                .tabItem {
                    VStack {
                        Image(systemName: "line.3.horizontal")
                        Text("MY PAGE")
                    }
                }
                .tag(3)
        }
        .accentColor(.black)
        .edgesIgnoringSafeArea(.all)
    }
}


struct NotificationBlock: View {
    let message: String

    var body: some View {
        HStack {
            Text(message)
                .padding()
            Spacer()
        }
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.vertical, 5)
    }
}

