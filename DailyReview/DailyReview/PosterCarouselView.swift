//
//  PosterCarouselView.swift
//  DailyReview
//
//  Created by 2022049898 on 11/6/24.
//

import SwiftUI
import UIKit

struct PosterCarouselView: UIViewControllerRepresentable {
    let posters: [String]

    func makeUIViewController(context: Context) -> HighlightingCollectionViewController {
        let viewController = HighlightingCollectionViewController(posters: posters)
        return viewController
    }

    func updateUIViewController(_ uiViewController: HighlightingCollectionViewController, context: Context) {}
}

class HighlightingCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    let posters: [String]
    
    init(posters: [String]) {
        self.posters = posters
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
        
        // Scroll to the center item after the view layout is complete
        DispatchQueue.main.async {
            let initialIndexPath = IndexPath(item: self.posters.count / 2, section: 0)
            self.collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
            self.updateVisibleCells()
        }
    }
    
    private func updateVisibleCells() {
        guard let visibleCells = collectionView?.visibleCells else {
            return
        }
        let centerX = collectionView.bounds.size.width / 2
        for cell in visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }
            let offset = abs(collectionView.convert(cell.center, to: collectionView.superview).x - centerX)
            let scale = max(0.85, 1 - offset / collectionView.frame.size.width)
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            cell.alpha = 1 - (offset / collectionView.frame.size.width) * 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        if let imageView = cell.contentView.subviews.first as? UIImageView {
            imageView.image = UIImage(named: posters[indexPath.item])
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
