//
//  WishListFolderModel.swift
//  DailyReview
//
//  Created by Lee Hyun on 11/17/24.
//

import SwiftUI

class WishListFolder: ObservableObject {
    @Published var wishLists: [String:[Movie]] = [:]
    
    // 새로운 위시리스트 추가
    func addNewWishList(name: String) {
        wishLists[name] = []
    }
    
    func deleteWishList(name: String) {
        wishLists.removeValue(forKey: name)
    }

    func addMovieToWishList(name: String, movie: Movie) {
        guard let wishList = wishLists[name] else { return }
        
        if !wishList.contains(where: { $0.id == movie.id }) {
            wishLists[name]?.append(movie)
        }
    }
    
    func removeMovieToWishList(name: String, movie: Movie) {
        if let index = wishLists[name]?.firstIndex(where: { $0.id == movie.id }) {
            wishLists[name]?.remove(at: index)
        }
    }
    
    func getPoster(name: String) -> String? {
        if let wishList = wishLists[name] {
            if let movie = wishList.first {
                return movie.poster
            }
        }
        return nil
    }
}
