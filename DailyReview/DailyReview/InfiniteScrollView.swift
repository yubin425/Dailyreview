//
//  InfiniteScroll.swift
//  DailyReview
//
//  Created by 2022049898 on 12/14/24.
//

import SwiftUI

// Define the Poster struct
struct Poster {
    var id: UUID
    var posterURL: String
}

struct InfiniteScrollView: View {
    @State private var posters: [Poster] = []
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var isLoading: Bool = true // Track loading state
    
    var reviews: [Review] // Accept reviews as input
    
    private let centerPosterWidth: CGFloat = 250 // Larger size for center poster
    private let sidePosterWidth: CGFloat = 150  // Smaller size for side posters
    private let spacing: CGFloat = 20  // Increased spacing to avoid collisions
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView() // Show loading indicator while posters are loading
            } else if posters.isEmpty {
                Text("No posters available") // Fallback message when no valid posters are found
                    .padding()
                    .foregroundColor(.gray)
            } else {
                PosterCarouselView(posters: posters, currentIndex: $currentIndex)
                    .frame(height: centerPosterWidth)
                    .onAppear {
                        fetchPosters()
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                isDragging = false
                                let dragThreshold: CGFloat = 50
                                
                                if dragOffset < -dragThreshold {
                                    // Move to the next poster
                                    currentIndex = (currentIndex + 1) % posters.count
                                } else if dragOffset > dragThreshold {
                                    // Move to the previous poster
                                    currentIndex = (currentIndex - 1 + posters.count) % posters.count
                                }
                                
                                dragOffset = 0
                            }
                    )
            }
        }
    }
    
    // Fetch posters based on reviews
    func fetchPosters() {
        // Filter out reviews without a valid poster URL
        let fetchedPosters = reviews.compactMap { review -> Poster? in
            guard let posterURL = review.movieStorage.poster,
                  let _ = URL(string: posterURL), // Ensure the URL is valid
                  !posterURL.isEmpty else { return nil } // Ensure the URL is not empty
            return Poster(id: review.movieStorage.id, posterURL: posterURL)
        }
        
        // Update the posters array with valid posters only
        self.posters = fetchedPosters
        self.isLoading = false // Stop loading
        
        // If no posters were found, print a message for debugging
        if fetchedPosters.isEmpty {
            print("No valid posters found.")
        }
    }
}

struct PosterCarouselView: View {
    var posters: [Poster]
    @Binding var currentIndex: Int
    
    private let centerPosterWidth: CGFloat = 250
    private let sidePosterWidth: CGFloat = 150
    private let spacing: CGFloat = 20
    private let scrollThreshold: CGFloat = 50
    
    private var totalPosters: Int {
        posters.count
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollViewProxy in
                    HStack(spacing: spacing) {
                        ForEach(0..<totalPosters * 3, id: \.self) { index in
                            let adjustedIndex = index % totalPosters
                            let poster = posters[adjustedIndex]
                            let isCentered = adjustedIndex == currentIndex
                            
                            PosterView(poster: poster, isCentered: isCentered)
                                .frame(width: isCentered ? centerPosterWidth : sidePosterWidth)
                                .scaleEffect(isCentered ? 1.2 : 0.8)  // Scaling effect
                                .opacity(isCentered ? 1.0 : 0.6)  // Opacity effect
                                .onTapGesture {
                                    currentIndex = adjustedIndex
                                    scrollToCenter(scrollViewProxy: scrollViewProxy, index: adjustedIndex)
                                }
                        }
                    }
                    .padding(.horizontal, (geometry.size.width - (centerPosterWidth + sidePosterWidth * 2 + spacing)) / 2)
                    .offset(x: CGFloat(currentIndex) * -(centerPosterWidth + spacing))
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragThreshold: CGFloat = 50
                                if value.translation.width < -dragThreshold {
                                    // Next poster
                                    currentIndex = (currentIndex + 1) % totalPosters
                                } else if value.translation.width > dragThreshold {
                                    // Previous poster
                                    currentIndex = (currentIndex - 1 + totalPosters) % totalPosters
                                }
                            }
                    )
                }
            }
            .frame(height: centerPosterWidth) // Adjust height for center poster size
            .clipped()
        }
    }
    
    // Scroll to the center of the poster
    private func scrollToCenter(scrollViewProxy: ScrollViewProxy, index: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            scrollViewProxy.scrollTo(index, anchor: .center)
        }
    }
}

struct PosterView: View {
    var poster: Poster
    var isCentered: Bool
    
    var body: some View {
        VStack {
            Text(poster.posterURL)  // For debugging
                .padding()
            
            AsyncImage(url: URL(string: poster.posterURL)) { image in
                image.resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: isCentered ? 10 : 2)
            } placeholder: {
                Color.gray
                    .cornerRadius(10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isCentered ? Color.white : Color.clear, lineWidth: 4)
            )
            .padding(4)
        }
    }
}
