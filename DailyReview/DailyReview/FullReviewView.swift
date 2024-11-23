//
//  FullReviewView.swift
//  DailyReview
//
//  Created by 임유빈 on 11/23/24.
//

import SwiftUI


struct FullReviewView: View {
    @State var review: Review
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // 포스터 표시
                GeometryReader { geometry in
                                VStack {
                                    Image("testImage")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: 300)
                                        .clipped()
                                        .overlay(Color.white.opacity(0.7))
                                        .overlay(
                                            VStack(alignment: .center) {
                                                HStack {
                                                    Image("testImage")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 150)
                                                        .padding(.horizontal)
                                                    Spacer()
                                                    
                                                    VStack {
                                                        Text("\(review.movieStorage.title)")
                                                            .font(.title)
                                                            .foregroundColor(.black)
                                                            .multilineTextAlignment(.center)
                                                            .padding(.bottom, 5)
                                                        //Text("\(String(movie.director.first ?? "null")),\(String(movie.releaseYear ?? "null"))")
                                                        //Text("\(String(movie.plotText ?? "null"))")
                                                            .multilineTextAlignment(.center)
                                                        
                                                        HStack {
                                                            ForEach(1...5, id: \.self) { index in
                                                                Image(systemName: index <= review.rating ? "star.fill" : "star")
                                                                    .resizable()
                                                                    .frame(width: 30, height: 30)
                                                                    .foregroundColor(index <= review.rating ? .orange : .black)
                                                            }
                                                        }
                                                    }
                                                    .padding(.horizontal)
                                                }
                                                
                                                HStack {
                                                    //Text("출연자:\(String(movie.director.first ?? "null"))")
                                                        //.lineLimit(1)
                                                        //.truncationMode(.tail)
                                                    
                                                    Spacer()
                                                    
                                                    //Text(Tags)
                                                        //.lineLimit(1)
                                                        //.truncationMode(.tail)
                                                }
                                                .padding(.horizontal)
                                                .padding(.top, 5)
                                            }
                                        )
                                }
                            }
                            .background(Color.white.opacity(0.3))
                            .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 리뷰 정보 표시
                    Text("Watched on: \(review.watchDate.formatted(date: .long, time: .omitted))")
                        .font(.subheadline)
                    
                    Text("Rating: \(review.rating)/5")
                        .font(.subheadline)
                    
                    Text("Location: \(review.watchLocation)")
                        .font(.subheadline)
                    
                    Text("Friends: \(review.friends)")
                        .font(.subheadline)
                    
                    Divider()
                    
                    // 커스텀 필드 표시
                    if let customFields = review.customFields, !customFields.isEmpty {
                        Text("Custom Fields:")
                            .font(.headline)
                        
                        ForEach(customFields) { field in
                            HStack {
                                Text("\(field.name):")
                                    .bold()
                                Text(field.value)
                            }
                        }
                    } else {
                        Text("No custom fields added.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // 상세 리뷰 텍스트
                    Text("Review:")
                        .font(.headline)
                    Text(review.reviewText)
                        .font(.body)
                }
                .padding()
                
                Spacer()
                
                // 수정 버튼
                Button("Edit Review") {
                    // 수정 화면으로 이동
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .navigationTitle("Review Details")
    }
}
