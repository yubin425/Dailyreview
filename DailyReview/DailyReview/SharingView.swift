//
//  SharingView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/29/24.
//

import SwiftUI

struct SharingView: View {
    @State private var screenshotImage: UIImage?
    @State private var isEditing = false

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
                    isEditing.toggle()
                }) {
                    Text("Edit Screenshot")
                        .padding()
                        .background(Color.purple)
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
            .sheet(isPresented: $isEditing) {
                EditScreenshotView(screenshotImage: $screenshotImage)
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

struct EditScreenshotView: View {
    @Binding var screenshotImage: UIImage?
    
    var body: some View {
        VStack {
            if let screenshotImage = screenshotImage {
                Image(uiImage: screenshotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
            }

            HStack {
                Button(action: {
                    applyEdgeDesign1()
                }) {
                    Text("Edge Design 1")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    applyEdgeDesign2()
                }) {
                    Text("Edge Design 2")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    func applyEdgeDesign1() {
        guard let screenshot = screenshotImage else { return }

        let renderer = UIGraphicsImageRenderer(size: screenshot.size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: screenshot.size)
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fill(rect)
            context.cgContext.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 10, dy: 10), cornerRadius: 20).cgPath)
            context.cgContext.clip()
            screenshot.draw(in: rect)
        }
        
        screenshotImage = image
    }


    func applyEdgeDesign2() {
        guard let screenshot = screenshotImage else { return }

        let renderer = UIGraphicsImageRenderer(size: screenshot.size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: screenshot.size)
            context.cgContext.setFillColor(UIColor.green.cgColor)
            context.cgContext.fill(rect)
            context.cgContext.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 10, dy: 10), cornerRadius: 20).cgPath)
            context.cgContext.clip()
            screenshot.draw(in: rect)
        }
        
        screenshotImage = image
    }
}

#Preview {
    SharingView()
}
