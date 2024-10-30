//
//  ContentView.swift
//  DailyReview
//
//  Created by 임유빈 on 10/28/24.
//

import SwiftUI
import SwiftData
import UIKit

class HighlightingCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    let posters = ["poster1", "poster2", "poster3", "poster4", "poster5"]
    override func viewDidLoad() { super.viewDidLoad()
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
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 600)
        ])
        
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
        return CGSize(width: collectionView.frame.width * 0.7, height: collectionView.frame.height * 0.8) }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let centerX = scrollView.contentOffset.x + scrollView.frame.size.width / 2
        for cell in
            collectionView.visibleCells {
            let offset = abs(cell.center.x - centerX
            )
            let scale = max(0.85, 1 - offset / scrollView.frame.size.width)
            cell.transform = CGAffineTransform(scaleX: scale, y: scale) } }
}

    class PosterCell: UICollectionViewCell {
        let imageView: UIImageView
        
        override init(frame: CGRect) { imageView = UIImageView(frame: .zero)
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
        ]) }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") } }
 
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

struct HighlightingCollectionView: UIViewControllerRepresentable {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onTapGesture {
                        ContentView()
                    }
                NavigationLink(destination: SearchResultsView())
                {
                    Text("Search")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Search")
        }
    }
    
    func makeUIViewController(context: Context) -> HighlightingCollectionViewController {
        return HighlightingCollectionViewController()
    }
    func updateUIViewController(_ uiViewController: HighlightingCollectionViewController, context: Context) {} }
struct HighlightingCollectionView_Previews: PreviewProvider {
    static var previews: some View { HighlightingCollectionView() .edgesIgnoringSafeArea(.all)
    }
}
struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    
    MainView()
        .modelContainer(for: Item.self, inMemory: true)
}

extension HighlightingCollectionViewController: UICollectionViewDelegateFlowLayout {}
