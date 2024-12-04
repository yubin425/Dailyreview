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

// Poster Carousel view which is used in SwiftUI
struct PosterCarouselView: UIViewControllerRepresentable {
    let reviews: [Review] // Using the Review model

    func makeUIViewController(context: Context) -> HighlightingCollectionViewController {
        // Filter out reviews without posters
        var filteredReviews = reviews.filter { review in
            guard let posterURL = review.movieStorage.poster else { return false }
            return !posterURL.isEmpty
        }

        // If there are fewer than 5 reviews, add dummy reviews
        if filteredReviews.count < 5 {
            let dummyCount = 5 - filteredReviews.count
            for _ in 0..<dummyCount {
                let movie1 = Movie(id: UUID(), title: "Inception", director: ["Christopher Nolan"], releaseYear: "2010", poster: "https://marketplace.canva.com/EAFTl0ixW_k/1/0/1131w/canva-black-white-minimal-alone-movie-poster-YZ-0GJ13Nc8.jpg", genre: ["Sci-Fi", "Action"], keyword: ["dream", "mind-bending"], plotText: "A thief who steals corporate secrets through the use of dream-sharing technology is given the task of planting an idea into the mind of a CEO.", actor: ["Leonardo DiCaprio", "Joseph Gordon-Levitt"])
                let movieStorage1 = movie1.toStorage()
                let review1 = Review(movieStorage: movieStorage1, reviewText: "Mind-blowing and intense!", rating: 5, watchDate: Date(), watchLocation: "Cinema A", friends: "John, Sarah")
                filteredReviews.append(review1)
            }
        }

        let viewController = HighlightingCollectionViewController(reviews: filteredReviews)
        return viewController
    }

    func updateUIViewController(_ uiViewController: HighlightingCollectionViewController, context: Context) {}
}

// Custom UICollectionView controller for horizontal scrolling
class HighlightingCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    let reviews: [Review]

    init(reviews: [Review]) {
        self.reviews = reviews
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

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
        collectionView.backgroundColor = .black
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

        DispatchQueue.main.async {
            let initialIndexPath = IndexPath(item: self.reviews.count / 2, section: 0)
            self.collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: true)
            self.updateVisibleCells()
        }
    }

    private func updateVisibleCells() {
        guard let visibleCells = collectionView?.visibleCells else { return }
        let centerX = collectionView.bounds.size.width / 2

        for cell in visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }

            // Calculate the distance from the center of the collection view
            let offset = abs(collectionView.convert(cell.center, to: collectionView.superview).x - centerX)

            // Adjust scale based on the offset
            let scale = max(0.85, 1 - offset / collectionView.frame.size.width)

            // Adjust opacity based on the offset
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
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

            // Safely unwrap the optional posterURL
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVisibleCells()
    }
}

// Poster Cell to display movie poster in the collection view
class PosterCell: UICollectionViewCell {
    let imageView: UIImageView

    override init(frame: CGRect) {
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true

        super.init(frame: frame)

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
