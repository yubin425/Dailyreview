//
//  InfiniteScroll.swift
//  DailyReview
//
//  Created by 2022049898 on 12/14/24.
//

import SwiftUI

// Poster model class
struct Poster: Identifiable {
    var id: UUID
    var posterURL: String
}

struct PosterCarousel: View {
    var posters: [Poster]
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private let centerPosterWidth: CGFloat = 250  // Larger size for the center poster
    private let sidePosterWidth: CGFloat = 150  // Smaller size for side posters
    private let spacing: CGFloat = 20  // Increased spacing to avoid collisions
    private let scaleFactor: CGFloat = 1.2  // Scale factor for the center poster
    private let opacityFactor: CGFloat = 0.4  // Opacity for non-centered posters
    
    private var totalPosters: Int {
        posters.count
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scrollViewProxy in
                    HStack(spacing: spacing) {
                        ForEach(0..<totalPosters, id: \.self) { index in
                            let poster = posters[index]
                            
                            // Determine if the poster is the center one
                            let isCentered = index == currentIndex
                            let posterWidth = isCentered ? centerPosterWidth : sidePosterWidth
                            
                            PosterView(poster: poster, isCentered: isCentered)
                                .frame(width: posterWidth)
                                .scaleEffect(isCentered ? scaleFactor : 1.0)  // Scale the centered poster
                                .opacity(isCentered ? 1.0 : opacityFactor) // Opacity for non-centered posters
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentIndex = index
                                        scrollToCenter(scrollViewProxy: scrollViewProxy, index: index)
                                    }
                                }
                        }
                    }
                    .frame(width: geometry.size.width, alignment: .center)
                    .padding(.horizontal, (geometry.size.width - centerPosterWidth) / 2) // Center the first poster
                    .offset(x: CGFloat(currentIndex) * -(centerPosterWidth + spacing)) // Offset adjusted by current index
                    .animation(.easeInOut(duration: 0.5), value: currentIndex)
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
                                    currentIndex = (currentIndex + 1) % totalPosters
                                } else if dragOffset > dragThreshold {
                                    currentIndex = (currentIndex - 1 + totalPosters) % totalPosters
                                }
                                
                                dragOffset = 0
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollToCenter(scrollViewProxy: scrollViewProxy, index: currentIndex)
                                }
                            }
                    )
                    .onAppear {
                        // Set the initial index to be the middle poster if possible
                        if !posters.isEmpty {
                            currentIndex = posters.count / 2
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollToCenter(scrollViewProxy: scrollViewProxy, index: currentIndex)
                        }
                    }
                    .onChange(of: currentIndex) { newValue in
                        // Ensure proper looping (infinite scroll behavior)
                        if newValue < 0 {
                            currentIndex = totalPosters - 1
                        } else if newValue >= totalPosters {
                            currentIndex = 0
                        }
                    }
                }
            }
            .frame(height: centerPosterWidth) // Height of the carousel
            .background(Color.black)  // Background color of the carousel
        }
    }
    
    private func scrollToCenter(scrollViewProxy: ScrollViewProxy, index: Int) {
        // Adjust the scroll position to center the selected poster
        withAnimation(.easeInOut(duration: 0.3)) {
            scrollViewProxy.scrollTo(index, anchor: .center)
        }
    }
}

struct PosterView: View {
    var poster: Poster
    var isCentered: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: poster.posterURL)) { image in
            image.resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: isCentered ? 10 : 2)
        } placeholder: {
            Color.gray.cornerRadius(10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isCentered ? Color.white : Color.clear, lineWidth: 4)
        )
        .padding(4)
    }
}

struct InfiniteScrollView: View {
    @State private var posters: [Poster] = []
    
    var reviews: [Review] // Accept reviews as input
    
    var body: some View {
        VStack {
            if posters.isEmpty {
                ProgressView()
            } else {
                PosterCarousel(posters: posters)
            }
        }
        .onAppear {
            fetchPosters()
        }
    }
    
    func fetchPosters() {
        // Fetch the movie posters from the reviews and movieStorage
        let fetchedPosters = reviews.compactMap { review -> Poster? in
            guard let posterURL = review.movieStorage.poster else { return nil }
            return Poster(id: review.movieStorage.id, posterURL: posterURL)
        }
        
        // Set the fetched posters
        self.posters = fetchedPosters
    }
}
