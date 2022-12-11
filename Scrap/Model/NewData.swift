//
//  NewData.swift
//  Scrap
//
//  Created by 김영선 on 2022/12/11.
//

import Foundation

struct NewData: Codable, Equatable {
    let title: String
    let imageUrl: String
    let url: String
    let categoryID: Int
    
    init(title: String, imageUrl: String, url: String, categoryID: Int) {
        self.title = title
        self.imageUrl = imageUrl
        self.url = url
        self.categoryID = categoryID
    }
}
