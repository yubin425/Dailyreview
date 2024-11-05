//
//  MovieDetailView.swift
//  DailyReview
//
//  Created by Lee Hyun on 11/5/24.
//


import SwiftUI

struct MovieDetailView: View {
    var movieDetail: MovieDetail // 선택한 영화의 상세 정보

    var body: some View {
        VStack {
            Text(movieDetail.movie.title)
                .font(.largeTitle)
            Text("감독: \(movieDetail.movie.director.joined(separator: ", "))")
            Text("개봉일: \(movieDetail.movie.releaseDate ?? "정보 없음")")
            Text("줄거리: \(movieDetail.plotText ?? "정보 없음")")
                .padding()
            Spacer()
        }
        .navigationTitle("영화 상세")
        .padding()
    }
}
