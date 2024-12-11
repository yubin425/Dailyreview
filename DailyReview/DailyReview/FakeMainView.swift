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
        VStack {
            if showSearchView {
                NavigationStack {
                    SearchView(Flag: "main")
                }
            } else {
                ZStack {
                    VStack(spacing: 0) {
                        Color.white
                            .frame(height: 100)

                        Color.black
                            .frame(height: 650)

                        Color.white
                            .frame(height: 100)
                    }

                    VStack {
                        PosterCarouselView(posters: posters)
                            .frame(height: 470)

                        TextField("Search...", text: $searchText)
                            .disabled(true)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .onTapGesture {
                                showSearchView = true
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
}

struct FakeMainView_Previews: PreviewProvider {
    static var previews: some View {
        FakeMainView()
            .edgesIgnoringSafeArea(.all)
    }
}
