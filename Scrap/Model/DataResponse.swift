//
//  DataResponse.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/27.
//

import Foundation

// MARK: - Data List
struct DataResponse: Codable {
    struct Result: Codable {
        var links: [Datas]
        
        init(links: [Datas]){
            self.links = links
        }
    }
    struct Datas: Codable, Identifiable{
        let id = UUID()
        var linkId : Int?
        var link: String?             //링크
        var title: String?            //자료 제목
        var domain: String?
        var imgUrl: String?           //자료 이미지
        
        init(linkId: Int, link: String, title: String, domain: String, imgUrl: String){
            self.linkId = linkId
            self.link = link
            self.title = title
            self.domain = domain
            self.imgUrl = imgUrl
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

// ------------------------------------------------------
// MARK: Data Model (API)

struct MoveDataModel: Codable {
    struct Result: Codable {
        var linkId: Int
        var categoryId: Int
        var url: String
        var title: String
        var imgUrl: String
        var domain: String
        
        init(linkId: Int, categoryId: Int, url: String, title: String, imgUrl: String, domain: String){
            self.linkId = linkId
            self.categoryId = categoryId
            self.url = url
            self.title = title
            self.imgUrl = imgUrl
            self.domain = domain
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

struct NewDataModel: Codable { //자료 저장 -> response 데이터로 받을 link id
    struct Result: Codable {
        var linkId: Int
        
        init(linkId: Int){
            self.linkId = linkId
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

struct NoResultModel: Codable {
    var code: Int
    var message: String
    init(code: Int, message: String){
        self.code = code
        self.message = message
    }
}
