//
//  NetworkErrors.swift
//  Scrap
//
//  Created by 김영선 on 2022/12/02.
//

import Foundation

enum NetworkErrors: Error {
    case requestFailed
    case responseUnsuccessFul(statusCode: Int)
    case invalidData
    case jsonParsingFailure
    case invalidURL
}
