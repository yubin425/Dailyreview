//
//  SearchView.swift
//  DailyReview
//
//  Created by 2022049898 on 10/29/24.
//

import SwiftUI

struct SearchView: View {
    @Binding var showSearchView: Bool
    @State private var searchText: String = ""

    var body: some View {
        NavigationSplitView {
            // Uncomment and add your list views
            // DepartmentList(departmentId: $departmentId)
        } content: {
            // Uncomment and add your product list views
            // ProductList(departmentId: departmentId, productId: $productId)
        } detail: {
            // Uncomment and add your product details views
            // ProductDetails(productId: productId)
        }
        .searchable(text: $searchText) // Adds a search field
        .padding(.top, 0)
        .navigationBarItems(leading: Button(action: {
            showSearchView = false
        }) {
            Text("Back")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        })
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(showSearchView: .constant(true))
    }
}
