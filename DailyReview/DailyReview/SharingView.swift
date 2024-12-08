//
//  SharingView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/29/24.
//

import SwiftUI

// Dummy movie data creation
let movie1 = Movie(id: UUID(), title: "Inception", director: ["Christopher Nolan"], releaseYear: "2010", poster: "https://m.media-amazon.com/images/I/51U2mb0PY5L._SY679_.jpg", genre: ["Sci-Fi", "Action"], keyword: ["dream", "mind-bending"], plotText: "A thief who steals corporate secrets through the use of dream-sharing technology is given the task of planting an idea into the mind of a CEO.", actor: ["Leonardo DiCaprio", "Joseph Gordon-Levitt"])
let movieStorage1 = movie1.toStorage()
let review1 = Review(movieStorage: movieStorage1, reviewText: "Mind-blowing and intense!", rating: 5, watchDate: Date(), watchLocation: "Cinema A", friends: "John, Sarah")

let movie2 = Movie(id: UUID(), title: "The Dark Knight", director: ["Christopher Nolan"], releaseYear: "2008", poster: "https://m.media-amazon.com/images/I/71lCw-XA2xL._SY679_.jpg", genre: ["Action", "Drama"], keyword: ["joker", "batman"], plotText: "When the menace known as The Joker emerges from his mysterious past, he wreaks havoc and chaos on the people of Gotham.", actor: ["Christian Bale", "Heath Ledger"])
let movieStorage2 = movie2.toStorage()
let review2 = Review(movieStorage: movieStorage2, reviewText: "A masterpiece, especially Ledger's performance!", rating: 5, watchDate: Date(), watchLocation: "Cinema B", friends: "Mike, Anna")

let movie3 = Movie(id: UUID(), title: "The Matrix", director: ["Lana Wachowski", "Lilly Wachowski"], releaseYear: "1999", poster: "https://m.media-amazon.com/images/I/51EG732BV4L._SY679_.jpg", genre: ["Sci-Fi", "Action"], keyword: ["reality", "simulation"], plotText: "A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.", actor: ["Keanu Reeves", "Laurence Fishburne"])
let movieStorage3 = movie3.toStorage()
let review3 = Review(movieStorage: movieStorage3, reviewText: "One of the most groundbreaking films in cinema history.", rating: 5, watchDate: Date(), watchLocation: "Cinema C", friends: "Tom, Lily")

let movie4 = Movie(id: UUID(), title: "The Shawshank Redemption", director: ["Frank Darabont"], releaseYear: "1994", poster: "https://m.media-amazon.com/images/I/51NiGlapXlL._SY679_.jpg", genre: ["Drama"], keyword: ["prison", "hope"], plotText: "Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.", actor: ["Tim Robbins", "Morgan Freeman"])
let movieStorage4 = movie4.toStorage()
let review4 = Review(movieStorage: movieStorage4, reviewText: "A truly inspirational film about friendship and hope.", rating: 4, watchDate: Date(), watchLocation: "Cinema D", friends: "David")

let movie5 = Movie(id: UUID(), title: "Fight Club", director: ["David Fincher"], releaseYear: "1999", poster: "https://m.media-amazon.com/images/I/51X1L0l0T+L._SY679_.jpg", genre: ["Drama", "Thriller"], keyword: ["violence", "rebellion"], plotText: "An insomniac office worker and a soap salesman form an underground fight club that evolves into something much, much more.", actor: ["Brad Pitt", "Edward Norton"])
let movieStorage5 = movie5.toStorage()
let review5 = Review(movieStorage: movieStorage5, reviewText: "An intense and disturbing movie with a brilliant twist.", rating: 4, watchDate: Date(), watchLocation: "Cinema E", friends: "Jack, Jane")

// Now you can add them to your dummyMovies array
let dummyMovies: [Review] = [review1, review2, review3, review4, review5]



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

            // Only show buttons when not loading
            if !isLoading {
                HStack {
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

// PosterStackView showing movies and posters
struct PosterStackView: View {
    let reviews: [Review]  // List of reviews passed into this view
    let captureAction: (UIImage) -> Void
    @State private var imagesLoaded = 0 // Track number of images loaded
    @State private var isCaptureReady = false // Flag to indicate capture readiness

    var totalImages: Int {
        reviews.count // Total number of reviews
    }

    var body: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(reviews, id: \.id) { review in
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
                    Text("Choose Edge Design")
                        .padding()
                        .background(Color.purple)
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


import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    @Binding var edgeSize: CGFloat  // Binding to edge size
    var applyColor: () -> Void  // Callback to apply the color
    var resetEdgeDesign: () -> Void  // Callback to reset the edge design to its default state
    
    var body: some View {
        VStack {
            Text("Select Edge Color")
                .font(.headline)
                .padding()

            ColorPicker("Choose Color", selection: $selectedColor)
                .padding()

            // Slider for adjusting edge size
            VStack {
                Text("Edge Size: \(Int(edgeSize))")
                    .font(.subheadline)
                    .padding()

                Slider(value: $edgeSize, in: 0...50, step: 1)
                    .padding()
            }

            Button(action: {
                applyColor()  // Apply the selected color
            }) {
                Text("Apply Edge Design")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Reset the edge design to the default state
            Button(action: {
                resetEdgeDesign()  // Reset the edge design to its default state
            }) {
                Text("Reset Edge Design")
                    .padding()
                    .foregroundColor(.red)
                    .underline()
            }
            .padding()
        }
        .padding()
    }
}
