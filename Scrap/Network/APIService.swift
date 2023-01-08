//
//  APIService.swift
//  Scrap
//
//  Created by 김영선 on 2022/12/18.
//

import Foundation

class APIService {
    // MARK: fetch data from Server
    func fetchData<T: Codable>(_ type: T.Type, baseUrl: URL?, completionHandler completion: @escaping(Result<T, APIErrors>) -> ()){
        guard let url = baseUrl else {
            completion(Result.failure(APIErrors.badURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error as? URLError {
                print(error)
                completion(Result.failure(APIErrors.url(error)))
            }else if let httpResponse = response as? HTTPURLResponse,
                     !(200..<300).contains(httpResponse.statusCode) {
                completion(Result.failure(APIErrors.badResponse(statusCode: httpResponse.statusCode)))
            }else if let data = data {
                do{
                    let result = try JSONDecoder().decode(type, from: data)
                    completion(Result.success(result))
                }catch let error {
                    print(error)
                    completion(Result.failure(APIErrors.parsingError(error as? DecodingError)))
                }
            }
        }
        task.resume()
    }
    
    // MARK: request task To Server
    func requestTask<T: Codable>(_ type: T.Type, withRequest request: URLRequest, completionHandler completion: @escaping(Result<T, APIErrors>) -> ()){
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error as? URLError {
                completion(Result.failure(APIErrors.url(error)))
            }else if let httpResponse = response as? HTTPURLResponse,
                     !(200..<300).contains(httpResponse.statusCode) {
                completion(Result.failure(APIErrors.badResponse(statusCode: httpResponse.statusCode)))
            }else if let data = data {
                do{
                    let result = try JSONDecoder().decode(type, from: data)
                    completion(Result.success(result))
                }catch let error {
                    completion(Result.failure(APIErrors.parsingError(error as? DecodingError)))
                }
            }
        }
        task.resume()
    }
}
