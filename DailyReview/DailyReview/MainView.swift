//
//  ContentView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/28/24.
//

import SwiftUI
import UIKit

class HighlightingCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    let posters = ["poster1", "poster2", "poster3", "poster4", "poster5"]
    var isInitialLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            let initialIndexPath = IndexPath(item: self.posters.count / 2, section: 0)
            self.collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
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
        
        if isInitialLoad && indexPath.item == posters.count / 2 {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            cell.alpha = 1.0
        } else {
            cell.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            cell.alpha = 0.5
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.7, height: collectionView.frame.height * 0.8)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isInitialLoad = false
        let centerX = scrollView.contentOffset.x + scrollView.frame.size.width / 2
        for cell in collectionView.visibleCells {
            let offset = abs(cell.center.x - centerX)
            let scale = max(0.85, 1 - offset / scrollView.frame.size.width)
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            cell.alpha = 1 - (offset / scrollView.frame.size.width) * 0.5
        }
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

struct SearchResultsView: View {
    var body: some View {
        VStack {
            Text("This is the Search Results view")
                .padding()
            Spacer()
        }
        .navigationTitle("Search Results")
    }
}

struct MainView: View {
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Color.white
                    .frame(height: 100)
                
                Color.black
                    .frame(height: 650)
                
                Color.white
                    .frame(height: 100)
            }
            
            VStack {
                UIViewControllerWrapper()
                    .frame(height: 470)
                
                TextField("Search...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onTapGesture {
                        // 검색창
                    }
                
                VStack(spacing: 10) {
                    NotificationBlock(message: "통계\n1")
                    NotificationBlock(message: "통계\n2")
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        print("Button 1 pressed")
                    }) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30))
                            Text("SEARCH")
                                .font(.caption)
                        }
                        .frame(width: 50, height: 50)
                        .padding()
                        //.background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        print("Button 2 pressed")
                    }) {
                        VStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 36))
                            Text("REVIEW")
                                .font(.caption)
                        }
                        .frame(width: 50, height: 50)
                        .padding()
                        //.background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        print("Button 3 pressed")
                    }) {
                        VStack {
                            Image(systemName: "bookmark")
                                .font(.system(size: 28))
                            Text("WHISTLIST")
                                .font(.caption)
                        }
                        .frame(width: 60, height: 60)
                        .padding()
                        //.background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        print("Button 4 pressed")
                    }) {
                        VStack {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 50))
                            Text("MY PAGE")
                                .font(.caption)
                        }
                        .frame(width: 50, height: 50)
                        .padding()
                        //.background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct NotificationBlock: View {
    let message: String
    
    var body: some View {
        HStack {
            Text(message)
                .padding()
            Spacer()
        }
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.vertical, 5)
    }
}

struct UIViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HighlightingCollectionViewController {
        return HighlightingCollectionViewController()
    }
    
    func updateUIViewController(_ uiViewController: HighlightingCollectionViewController, context: Context) {}
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .edgesIgnoringSafeArea(.all)
    }
}

extension HighlightingCollectionViewController: UICollectionViewDelegateFlowLayout {}
