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
            if let screenshotImage = screenshotImage {
                Image(uiImage: screenshotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
            } else {
                Image("poster1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
            }

            HStack {
                Button(action: {
                    takeScreenshot()
                }) {
                    Text("Capture Screenshot")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    saveScreenshot()
                }) {
                    Text("Save Screenshot")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    shareScreenshot()
                }) {
                    Text("Share Screenshot")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
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

    func saveScreenshot() {
        guard let screenshot = screenshotImage else {
            return
        }

        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
    }

    func shareScreenshot() {
        guard let screenshot = screenshotImage else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)

        // Present the activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

#Preview {
    SharingView()
}
