//
//  PosterCarouselView.swift
//  DailyReview
//
//  Created by 2022049898 on 11/6/24.
//

import SwiftUI
import UIKit

// Fetch poster image asynchronously
private func fetchPosterImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data, let image = UIImage(data: data) {
            completion(image)
        } else {
            completion(nil)
        }
    }
    task.resume()
}

class Coordinator: NSObject {
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}


// Poster Carousel view which is used in SwiftUI
struct PosterCarouselView: UIViewControllerRepresentable {
    let reviews: [Review]
    
    func makeCoordinator() -> Coordinator {
        // You will pass the navigationController here
        return Coordinator(navigationController: UINavigationController())
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        var filteredReviews = reviews.filter { review in
            guard let posterURL = review.movieStorage.poster else { return false }
            return !posterURL.isEmpty
        }

        if filteredReviews.count < 5 {
            let dummyCount = 5 - filteredReviews.count
            for _ in 0..<dummyCount {
                let movie1 = Movie(id: UUID(), title: "Inception", director: ["Christopher Nolan"], releaseYear: "2010", poster: "https://marketplace.canva.com/EAFTl0ixW_k/1/0/1131w/canva-black-white-minimal-alone-movie-poster-YZ-0GJ13Nc8.jpg", genre: ["Sci-Fi", "Action"], keyword: ["dream", "mind-bending"], plotText: "A thief who steals corporate secrets through the use of dream-sharing technology is given the task of planting an idea into the mind of a CEO.", actor: ["Leonardo DiCaprio", "Joseph Gordon-Levitt"])
                let movieStorage1 = movie1.toStorage()
                let review1 = Review(movieStorage: movieStorage1, reviewText: "Mind-blowing and intense!", rating: 5, watchDate: Date(), watchLocation: "Cinema A", friends: "John, Sarah")
                filteredReviews.append(review1)
            }
        }
        
        // Create the view controller with the passed navigation controller
        let viewController = HighlightingCollectionViewController(reviews: filteredReviews, navController: context.coordinator.navigationController!)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}



import UIKit
import SwiftUI

class HighlightingCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    let reviews: [Review]
    
    // The navigationController will now be passed as a property
    var navController: UINavigationController?

    init(reviews: [Review], navController: UINavigationController) {
            self.reviews = reviews
            self.navController = navController // Ensure navController is passed in
            super.init(nibName: nil, bundle: nil)
        }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTapNotification(_:)), name: .didTapPosterCell, object: nil)
        DispatchQueue.main.async {
            let initialIndexPath = IndexPath(item: self.reviews.count / 2, section: 0)
            self.collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
            self.updateVisibleCells()
        }
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15

        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
        collectionView.backgroundColor = UIColor(named: "BackgroundColor") // 배경 색상 변경
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false

        self.view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }

    @objc private func handleTapNotification(_ notification: Notification) {
        print("Received tap notification!") // Confirm if the notification is received
        guard let review = notification.object as? Review else { return }
        
        let fullReviewView = FullReviewView(review: review)
        let hostingController = UIHostingController(rootView: fullReviewView)
        
        navController?.pushViewController(hostingController, animated: true)
    }

    
    private func updateVisibleCells() {
        guard let visibleCells = collectionView?.visibleCells else { return }
        let centerX = collectionView.bounds.size.width / 2

        // Loop through all visible cells to apply scaling and alpha effects
        for cell in visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }

            // Calculate the distance from the center of the collection view
            let offset = abs(collectionView.convert(cell.center, to: collectionView.superview).x - centerX)

            // Scale the cells based on distance from the center
            let scale = max(0.85, 1 - offset / collectionView.frame.size.width)
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)

            // Adjust opacity (alpha) of cells based on their distance
            cell.alpha = 1 - (offset / collectionView.frame.size.width) * 0.5
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell

        if let imageView = cell.contentView.subviews.first as? UIImageView {
            imageView.image = UIImage(systemName: "photo")

            if let posterURL = reviews[indexPath.item].movieStorage.poster, !posterURL.isEmpty,
               let url = URL(string: posterURL) {
                fetchPosterImage(from: url) { image in
                    DispatchQueue.main.async {
                        imageView.image = image ?? UIImage(systemName: "photo")
                    }
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.7, height: collectionView.frame.height * 0.8)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestPoster()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestPoster()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Continuously update the visible cells while scrolling
        updateVisibleCells()
    }

    private func scrollToNearestPoster() {
        let centerX = collectionView.bounds.size.width / 2
        let visibleCells = collectionView.visibleCells

        var closestIndexPath: IndexPath?
        var minimumDistance: CGFloat = CGFloat.greatestFiniteMagnitude

        for cell in visibleCells {
            let cellCenterX = collectionView.convert(cell.center, to: collectionView.superview).x
            let distance = abs(cellCenterX - centerX)

            if distance < minimumDistance {
                minimumDistance = distance
                if let indexPath = collectionView.indexPath(for: cell) {
                    closestIndexPath = indexPath
                }
            }
        }

        if let indexPath = closestIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension Notification.Name {
    static let didTapPosterCell = Notification.Name("didTapPosterCell")
}


// Poster Cell to display movie poster in the collection view
class PosterCell: UICollectionViewCell {
    let imageView: UIImageView
    var review: Review? // Store the review associated with this cell

    override init(frame: CGRect) {
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10 // 모서리 둥글게
        imageView.layer.borderWidth = 0.5 // 얇은 테두리
        imageView.layer.borderColor = UIColor.white.cgColor

        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.layer.shadowColor = UIColor.black.cgColor // 그림자
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = UIColor.clear

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        contentView.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Handle the tap gesture
    @objc private func didTapCell() {
        print("Poster cell tapped!") // Check if this is triggered
        guard let review = review else { return }
        NotificationCenter.default.post(name: .didTapPosterCell, object: review)
    }
}
