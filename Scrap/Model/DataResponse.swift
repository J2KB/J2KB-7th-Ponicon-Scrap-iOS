//
//  DataResponse.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/27.
//

import Foundation

struct DataResponse: Decodable{
    struct Result: Decodable{
        var links: [Datas]
        
        init(links: [Datas]){
            self.links = links
        }
    }
    struct Datas: Decodable, Identifiable{
        let id = UUID()
        var linkId : Int
        var link: String             //링크
        var title: String            //자료 제목
        var domain: String
        var imgUrl: String           //자료 이미지
        
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
