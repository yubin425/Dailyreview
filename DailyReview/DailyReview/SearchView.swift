//
//  SearchView.swift
//  DailyReview
//
//  Created by 2022049898 on 10/29/24.
//

import Foundation
import SwiftUI

struct ContentView: View {
   // @State private var departmentId: Department.ID?
   // @State private var productId: Product.ID?
    @State private var searchText: String = ""


    var body: some View {
        NavigationSplitView {
            //DepartmentList(departmentId: $departmentId)
        } content: {
            //ProductList(departmentId: departmentId, productId: $productId)
        } detail: {
            //ProductDetails(productId: productId)
        }
        .searchable(text: $searchText) // Adds a search field.
        
        .padding(.top, 325.0)
    }
}

#Preview {
    ContentView()
}


