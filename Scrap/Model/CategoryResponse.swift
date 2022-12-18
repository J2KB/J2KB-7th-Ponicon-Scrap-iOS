//
//  CategoryResponse.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/27.
//

import Foundation

struct CategoryResponse: Codable {
    struct Result: Codable {
        var categories: [Category]
        
        init(categories: [Category]){
            self.categories = categories
        }
    }
    struct Category: Codable, Identifiable, Equatable {
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

// ------------------------------------------------------
// MARK: Category Data Model (API)

struct CategoryModel: Codable { //카테고리 추가 -> response 데이터로 받을 user id
    struct Result: Codable {
        var categoryId: Int
        
        init(categoryId: Int){
            self.categoryId = categoryId
        }
    }
    var code: Int
    var message: String
    var result: Result?
    init(code: Int, message: String, result: Result){
        self.code = code
        self.message = message
        self.result = result
    }
}
