//
//  APIService.swift
//  Share
//
//  Created by 김영선 on 2022/12/20.
//

import Foundation

class APIService {
//    private let session: URLSession
//
//    init(configuration: URLSessionConfiguration) {
//        self.session = URLSession(configuration: configuration)
//    }
//
//    convenience init(){
//        self.init(configuration: .background(withIdentifier: "com.thk.Scrap")) //background networking
//    }
    
    func addDataToScrapCompletionHandler(withRequest request: URLRequest, completionHandler completion: @escaping (Result<NewDataModel, APIErrors>) -> ()) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error as? URLError {
                completion(Result.failure(APIErrors.url(error)))
            }else if let httpResponse = response as? HTTPURLResponse,
                     !(200..<300).contains(httpResponse.statusCode) {
                completion(Result.failure(APIErrors.badResponse(statusCode: httpResponse.statusCode)))
            }else if let data = data {
                do{
                    let result = try JSONDecoder().decode(NewDataModel.self, from: data)
                    completion(Result.success(result))
                }catch let error {
                    completion(Result.failure(APIErrors.parsingError(error as? DecodingError)))
                }
            }
        }.resume()
    }
}
