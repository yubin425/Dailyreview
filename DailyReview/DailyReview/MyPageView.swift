//
//  MyPageView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/29/24.
//

import SwiftUI
import SwiftData


struct MyPageView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Query private var reviews: [Review]
    var body: some View {
        VStack {
                   // Color Asset을 사용
                   Text("마이 페이지")
                       .font(.title)
                       .foregroundColor(Color("TextColor"))
                       .padding()
                   
                   // Toggle 버튼
                   Toggle("다크 모드", isOn: $isDarkMode)
                       .foregroundColor(.red)
                       .padding()
            VStack {
                StatisticsView(reviews: reviews,amount: 5)
            }
               }
               .preferredColorScheme(isDarkMode ? .dark : .light) // 다크 모드 설정
               .animation(.easeInOut, value: isDarkMode) // 애니메이션 효과
    }
}
