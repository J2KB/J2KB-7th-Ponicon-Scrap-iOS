//
//  UserResponse.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/29.
//

import Foundation

struct UserResponse: Codable {
    struct Result: Codable {
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

// ------------------------------------------------------
// MARK: User Data Model (API)
struct LoginModel: Codable {
    struct Result: Codable {
        var id: Int
        
        init(id: Int){
            self.id = id
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

struct CheckDuplication: Codable {
    struct Result: Codable {
        var isDuplicate: Bool
        
        init(isDuplicate: Bool){
            self.isDuplicate = isDuplicate
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

struct SignUpModel: Codable {
    var code: Int
    var message: String
    
    init(code: Int, message: String){
        self.code = code
        self.message = message
    }
}

struct LogOutModel: Codable {
    let code: Int
    let message: String
    init(code: Int, message: String){
        self.code = code
        self.message = message
    }
}

struct FailModel: Codable {
    let code: Int
    let message: String
}
