//
//  ReviewView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/29/24.
//

import SwiftUI
import SwiftData

@Model
    var type: String
    
    init(type: String) {
        self.type = type
    }
}

struct ReviewView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ReviewView()
}
