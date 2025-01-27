//
//  SharingView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/29/24.
//

import SwiftUI


// Main sharing view
struct SharingView: View {
    @State private var screenshotImage: UIImage?
    @State private var isEditing = false
    @State private var isLoading = true  // Track the loading state
    @State private var imagesLoaded = 0 // Track number of loaded images
    
    var reviews: [Review]
        
    // Get all poster URLs from the reviews
    var posterURLs: [String] {
        reviews.map { $0.movieStorage.poster ?? "" } // Get the poster URL from each review's MovieStorage
    }

    var totalImages: Int {
        posterURLs.count
    }

    var body: some View {
        VStack {
            
            if let screenshotImage = screenshotImage {
                Image(uiImage: screenshotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
            } else {
                PosterStackViewContainer(reviews: reviews) { screenshot in
                    self.screenshotImage = screenshot
                    self.isLoading = false  // Mark as not loading when screenshot is captured
                }
            }
            
            if !isLoading {
                HStack {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Image(systemName: "paintbrush")
                            .font(.system(size: 30))
                            .frame(width: 50, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        shareScreenshot()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 30))
                            .frame(width: 50, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sheet(isPresented: $isEditing) {
                    EditScreenshotView(screenshotImage: $screenshotImage)
                }
            }

            
        }
    }

    func shareScreenshot() {
        guard let screenshot = screenshotImage else { return }

        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)

        // Present the activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

// Poster stack view to display images
struct PosterStackViewContainer: UIViewControllerRepresentable {
    let reviews: [Review]  // Reviews passed into the container
    let captureAction: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIHostingController(rootView: PosterStackView(reviews: reviews, captureAction: captureAction))
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct PosterStackView: View {
    let reviews: [Review]  // List of reviews passed into this view
    let captureAction: (UIImage) -> Void
    @State private var imagesLoaded = 0 // Track number of images loaded
    @State private var isCaptureReady = false // Flag to indicate capture readiness

    var totalImages: Int {
        reviews.filter { review in
            guard let posterUrlString = review.movieStorage.poster else { return false }
            return !posterUrlString.isEmpty
        }.count // Total number of reviews with valid posters
    }

    // Define the number of columns dynamically based on screen width
    private var columns: [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let minItemWidth: CGFloat = 120  // Minimum width for each poster item
        
        // Calculate the number of columns based on screen width and min width
        let numberOfColumns = max(Int(screenWidth / minItemWidth), 1)  // Ensure at least 1 column

        return Array(repeating: GridItem(.flexible(), spacing: 5), count: numberOfColumns)
    }

    var body: some View {
        // Create a grid layout with the dynamic columns
        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(reviews.filter { review in
                guard let posterUrlString = review.movieStorage.poster else { return false }
                return !posterUrlString.isEmpty
            }, id: \.id) { review in
                // Access the poster URL from the movieStorage within the Review class
                if let posterUrlString = review.movieStorage.poster,
                   let posterUrl = URL(string: posterUrlString) {
                    
                    AsyncImage(url: posterUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .onAppear {
                                    imageLoaded() // Call image loaded handler if necessary
                                }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(8)
                    .padding(2)
                }
            }
        }
        .padding()
        .background(GeometryReader { geometry in
            Color.clear.onAppear {
                // Delay the screenshot capture until all images are loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if imagesLoaded == totalImages {
                        captureScreenshot(from: geometry)
                    }
                }
            }
        })
    }

    private func imageLoaded() {
        // Increment the loaded images counter
        imagesLoaded += 1
        if imagesLoaded == totalImages {
            isCaptureReady = true
        }
    }

    private func captureScreenshot(from geometry: GeometryProxy) {
        // Capture the portion of the screen that contains the PosterStackView
        let size = geometry.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            context.cgContext.translateBy(x: 0, y: -geometry.frame(in: .global).minY)
            UIApplication.shared.windows.first?.layer.render(in: context.cgContext)
        }
        captureAction(image)
    }
}



struct EditScreenshotView: View {
    @Binding var screenshotImage: UIImage?
    @State private var showColorPicker = false  // Flag to show the color picker modal
    @State private var selectedColor: Color = .red  // Default selected color
    @State private var originalScreenshot: UIImage?  // To store the original screenshot for reset
    @State private var edgeSize: CGFloat = 10  // Default edge size (can be adjusted by the user)
    
    var body: some View {
        VStack {
            if let screenshotImage = screenshotImage {
                Image(uiImage: screenshotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
            }

            // Horizontal stack for "Choose Edge Design" and "Share" buttons
            HStack {
                // "Choose Edge Design" button
                Button(action: {
                    showColorPicker.toggle()
                }) {
                    Text("테두리 디자인 정하기")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }

            // Display the color picker modal when the button is clicked
            .sheet(isPresented: $showColorPicker) {
                ColorPickerView(
                    selectedColor: $selectedColor,
                    edgeSize: $edgeSize,  // Pass edgeSize binding to ColorPickerView
                    applyColor: applyEdgeDesign,
                    resetEdgeDesign: resetEdgeDesign
                )
            }
        }
        .onAppear {
            if originalScreenshot == nil, let currentScreenshot = screenshotImage {
                originalScreenshot = currentScreenshot
            }
        }
    }

    // Function to apply the selected color and edge size as the edge design
    func applyEdgeDesign() {
        guard let screenshot = screenshotImage else { return }
        
        // Convert the selected Color to UIColor
        let selectedUIColor = UIColor(selectedColor)
        
        let renderer = UIGraphicsImageRenderer(size: screenshot.size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: screenshot.size)
            
            // Set the fill color based on the selected color
            context.cgContext.setFillColor(selectedUIColor.cgColor)
            context.cgContext.fill(rect)
            
            // Apply the rounded edge with dynamic size
            context.cgContext.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: edgeSize, dy: edgeSize), cornerRadius: edgeSize).cgPath)
            context.cgContext.clip()
            
            // Draw the screenshot over the clipped area
            screenshot.draw(in: rect)
        }
        
        // Update the screenshot with the new image
        screenshotImage = image
        
        // Close the modal after applying the color
        showColorPicker = false
    }

    // Function to reset the edge design to the default state (no edge)
    func resetEdgeDesign() {
        guard let originalScreenshot = originalScreenshot else { return }
        
        // Reset the screenshot image to the original state (no edge or color)
        screenshotImage = originalScreenshot
        
        // Close the modal after resetting the design
        showColorPicker = false
    }

    // Function to share the screenshot
    func shareScreenshot() {
        guard let screenshot = screenshotImage else { return }
        
        // Create the UIActivityViewController for sharing the image
        let activityController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        
        // Present the share sheet on the root view controller
        if let controller = UIApplication.shared.windows.first?.rootViewController {
            controller.present(activityController, animated: true, completion: nil)
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Binding var edgeSize: CGFloat  // Binding to edge size
    var applyColor: () -> Void  // Callback to apply the color
    var resetEdgeDesign: () -> Void  // Callback to reset the edge design to its default state
    
    var body: some View {
        VStack {
            Text("테두리 색 정하기")
                .font(.headline)
                .padding()

            ColorPicker("색 선택하기", selection: $selectedColor)
                .padding()

            // Slider for adjusting edge size
            VStack {
                Text("테두리 크기: \(Int(edgeSize))")
                    .font(.subheadline)
                    .padding()

                Slider(value: $edgeSize, in: 0...50, step: 1)
                    .padding()
            }

            Button(action: {
                applyColor()  // Apply the selected color
            }) {
                Text("적용하기")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Reset the edge design to the default state
            Button(action: {
                resetEdgeDesign()  // Reset the edge design to its default state
            }) {
                Text("테두리 초기화")
                    .padding()
                    .foregroundColor(.red)
                    .underline()
            }
            .padding()
        }
        .padding()
    }
}
