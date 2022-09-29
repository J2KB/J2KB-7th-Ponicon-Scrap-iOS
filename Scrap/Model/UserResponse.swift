//
//  UserResponse.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/29.
//

import Foundation

struct UserResponse: Decodable{
    struct Result: Decodable {
        var name: String
        var username: String
        
        init(name: String, username: String){
            self.name = name
            self.username = username
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
