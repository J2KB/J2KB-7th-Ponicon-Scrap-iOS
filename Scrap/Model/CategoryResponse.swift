//
//  CategoryResponse.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/27.
//

import Foundation

//CategoryData

struct CategoryResponse: Decodable{
    struct Result: Decodable {
        var categories: [Category]
        
        init(categories: [Category]){
            self.categories = categories
        }
    }
    struct Category: Decodable, Identifiable, Equatable {
        let id = UUID()
        var categoryId: Int
        var name: String
        var numOfLink: Int
        var order: Int
        
        init(categoryId: Int, name: String, numOfLink: Int, order: Int){
            self.categoryId = categoryId
            self.name = name
            self.numOfLink = numOfLink
            self.order = order
        }
    }
    var code: Int
    var message: String
    var result: Result
    
    init(code: Int, message: String, result: Result){
        self.code = code
        self.message = message
        self.result = result
    }
}
