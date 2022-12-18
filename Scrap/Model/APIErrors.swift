//
//  NetworkErrors.swift
//  Scrap
//
//  Created by 김영선 on 2022/12/02.
//

import Foundation

enum APIErrors: Error, CustomStringConvertible {
    case badURL
    case badResponse(statusCode: Int)
    case url(URLError)
    case parsingError(DecodingError?)
    case unknown
    
    // MARK: - user feedback
    var localizedDescription: String {
        switch self {
        case .badURL, .parsingError, .unknown:
            return "Sorry, something went wrong."
        case .badResponse(_):
            return "Sorry, the connection to our server failed"
        case .url(let error):
            return error.localizedDescription
        }
    }
    
    // MARK: - information for debuging
    var description: String {
        switch self {
        case .unknown: return "unknown error"
        case .badURL: return "invalid URL"
        case .url(let error):
            return error.localizedDescription
        case .parsingError(let error):
            return "parsing error \(error?.localizedDescription ?? "")"
        case .badResponse(statusCode: let statusCode):
            return "bad response with status code \(statusCode)"
        }
    }
}
