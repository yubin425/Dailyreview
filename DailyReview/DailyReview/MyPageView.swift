//
//  MyPageView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/29/24.
//

import SwiftUI

struct MyPageView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack {
                   // Color Asset을 사용
                   Text("다크 모드")
                       .font(.title)
                       .foregroundColor(Color("Positivecolor"))
                       .padding()
                   
                   // Toggle 버튼
                   Toggle("다크 모드", isOn: $isDarkMode)
                       .padding()
               }
               .preferredColorScheme(isDarkMode ? .dark : .light) // 다크 모드 설정
               .animation(.easeInOut, value: isDarkMode) // 애니메이션 효과
    }
}
