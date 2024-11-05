//
//  SharingView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/29/24.
//

import SwiftUI

struct SharingView: View {
    @State private var screenshotImage: UIImage?

    var body: some View {
        VStack {
            Button(action: {
                takeScreenshot()
            }) {
                Text("Capture Screenshot")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Image("poster1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding()
            
            if let screenshotImage = screenshotImage {
                Image(uiImage: screenshotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
            }
        }
    }

    func takeScreenshot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            window.layer.render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if let screenshot = screenshot {
                DispatchQueue.main.async {
                    self.screenshotImage = screenshot
                }
            }
        }
    }
}


#Preview {
    SharingView()
}
