//
//  NewDataModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/12/11.
//

import Foundation

struct NewData: Codable, Equatable {
    let title: String
    let imgUrl: String
    let url: String
    
    init(title: String, imgUrl: String, url: String) {
        self.title = title
        self.imgUrl = imgUrl
        self.url = url
    }
}
