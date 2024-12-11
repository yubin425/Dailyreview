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
                    VStack(spacing: 0) {
                        Color.white
                            .frame(height: 100)

                        Color.black
                            .frame(height: 650)

                        Color.white
                            .frame(height: 100)
                    }

                    VStack {
                        PosterCarouselView(reviews: reviews)
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

                        VStack {
                            StatisticsView(reviews: reviews)
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                }

                // Navigation Link for the search view
                NavigationLink(
                    destination: SearchView(Flag: "main"),
                    isActive: $showSearchView,
                    label: {
                        EmptyView()
                    }
                )
                .hidden() // Hide the actual navigation link view
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
