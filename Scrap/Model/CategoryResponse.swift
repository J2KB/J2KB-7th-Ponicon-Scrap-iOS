//
//  CategoryResponse.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/27.
//

import Foundation

struct CategoryResponse: Decodable{
    struct Result: Decodable {
        let categories: [Category]
        
        init(categories: [Category]){
            self.categories = categories
        }
    }
    struct Category: Decodable, Identifiable{
        let id = UUID()
        let categoryId: Int
        let name: String
        let numOfLink: Int
        let order: Int
        
        init(categoryId: Int, name: String, numOfLink: Int, order: Int){
            self.categoryId = categoryId
            self.name = name
            self.numOfLink = numOfLink
            self.order = order
        }
    }
    let code: Int
    let message: String
    var result: Result
    
    init(code: Int, message: String, result: Result){
        self.code = code
        self.message = message
        self.result = result
    }
}
