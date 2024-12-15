//
//  SelectView.swift
//  DailyReview
//
//  Created by 2022049898 on 12/4/24.
//

import SwiftUI

struct ReviewSelectionView: View {
    @State private var selectedReviews: Set<UUID> = [] // Track selected reviews
    @State private var selectAll = false // Track select-all state
    @State private var navigateToSharingView = false // State to trigger navigation
    
    let reviews: [Review] // List of reviews passed in
    
    var body: some View {
        NavigationStack {
            VStack {

                List(reviews) { review in
                    HStack {
                        // Movie Poster
                        if let posterURL = review.movieStorage.poster, let url = URL(string: posterURL) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 75)
                            } placeholder: {
                                Color.gray.frame(width: 50, height: 75)
                            }
                        } else {
                            Color.gray.frame(width: 50, height: 75)
                        }
                        
                        // Movie Title
                        VStack(alignment: .leading) {
                            Text(review.movieStorage.title)
                                .font(.headline)
                            
                            Text("별점: \(ratingStars(rating: review.rating))")
                                .font(.subheadline)
                            
                            Text("리뷰한 날짜: \(formattedDate(review.watchDate))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        // Custom Checkbox Button to select the review
                        Button(action: {
                            toggleReviewSelection(review.id)
                        }) {
                            Image(systemName: selectedReviews.contains(review.id) ? "checkmark.square" : "square")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(selectedReviews.contains(review.id) ? .red : .gray)
                        }
                        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid default button styles
                    }
                    .padding()
                }
                
                HStack{
                    Button(action: {
                        toggleSelectAll()
                    }) {
                        Text(selectAll ? "전체 선택 해제" : "전체 선택하기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    // Button to confirm selected reviews
                    Button(action: {
                        confirmSelection()
                    }) {
                        Text("공유하기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedReviews.isEmpty ? Color.gray : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(selectedReviews.isEmpty)
                    .padding()
                }
                // Navigation link for SharingView
                NavigationLink(
                    destination: SharingView(reviews: selectedReviews.map { id in
                        reviews.first { $0.id == id }!
                    }),
                    isActive: $navigateToSharingView,
                    label: { EmptyView() }
                )
            }
            .navigationTitle("공유할 리뷰 선택")
        }
    }
    
    // Helper method to format date
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    // Helper method to generate stars for the rating
    func ratingStars(rating: Int) -> String {
        let fullStars = String(repeating: "★", count: rating)
        let emptyStars = String(repeating: "☆", count: 5 - rating)
        return fullStars + emptyStars
    }
    
    // Toggle the select-all state
    func toggleSelectAll() {
        selectAll.toggle()
        if selectAll {
            selectedReviews = Set(reviews.map { $0.id })
        } else {
            selectedReviews.removeAll()
        }
    }
    
    // Toggle selection of an individual review
    func toggleReviewSelection(_ reviewId: UUID) {
        if selectedReviews.contains(reviewId) {
            selectedReviews.remove(reviewId)
        } else {
            selectedReviews.insert(reviewId)
        }
    }
    
    // Confirm selection action (trigger navigation to SharingView)
    func confirmSelection() {
        navigateToSharingView = true
    }
}
