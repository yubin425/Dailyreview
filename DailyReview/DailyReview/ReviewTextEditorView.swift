//
//  ReviewTextEditorView.swift
//  DailyReview
//
//  Created by 임유빈 on 11/6/24.
//

import SwiftUI

struct ReviewTextEditorView: View {
    @Binding var reviewText: String
    var body: some View {
        Text("상세 리뷰 작성")
        GeometryReader { geometry in
            VStack{
                TextEditor(text: $reviewText)
                    .frame(width: geometry.size.width, height: 700) // 지정된 크기
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    .transition(.slide) // 슬라이드로 나타나는 애니메이션}
            }
        }
        .padding(.horizontal)
        Button(action: {

                   }) {
                       Text("완료")
                           .padding()
                           .background(Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(8)
                   }    }
}
    
#Preview {
    @State var sampleText = "미리보기용 텍스트"
    return ReviewTextEditorView(reviewText: $sampleText)
}
