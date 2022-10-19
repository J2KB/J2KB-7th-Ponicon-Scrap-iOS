//
//  ScrapViewModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/29.
//

import Foundation

struct NewCategoryModel: Decodable{ //카테고리 추가 -> response 데이터로 받을 user id
    struct Result: Decodable {
        var categoryId: Int
        
        init(categoryId: Int){
            self.categoryId = categoryId
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

struct NewDataModel: Decodable{ //자료 저장 -> response 데이터로 받을 link id
    struct Result: Decodable {
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

class ScrapViewModel: ObservableObject{ //감시할 data model
    //api 서버 통신을 통해 받아온 데이터를 아래의 객체에 담는다. Published 객체이므로 이 객체 데이터의 변동사항을 다른 view에서 동기적으로 업데이트한다.
    //카테고리 정보를 담은 categoryList 객체
    //카테고리에 따른 자료 정보를 담은 dataList 객체
    //사용자 정보를 담는 user 객체 -> 마이페이지에서 사용할 것
    @Published var dataList = DataResponse(code: 0, message: "", result: DataResponse.Result(links: [DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")]))
    @Published var user = UserResponse(code: 0, message: "", result: UserResponse.Result(name: "", username: ""))
    @Published var categoryList = CategoryResponse(code: 0, message: "",
                                                   result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)]))

    var failedLoginToastMessage = ""
    var categoryID = 0
    
    //categoryList에 category 추가 함수 (카테고리 추가 기능)
    func appendCategory(newCategory: CategoryResponse.Category){
        categoryList.result.categories.append(newCategory)
    }
    
    //GET
    //카테고리 전체 조회
    func getCategoryData(userID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/category/all?id=\(userID)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CategoryResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.categoryList = result
                    }
                } else {
                    print("no data")
                }
            }catch (let error){
                print("error")
                print(String(describing: error))
            }
        }.resume()
    }
    
    //자료 조회 -> query: category id
    func getData(userID: Int, catID: Int, seq: String){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/data?id=\(userID)&category=\(catID)&seq=\(seq)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(DataResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.dataList = result
                    }
                } else {
                    print("no data")
                }
            }catch (let error){
                print("error")
                print(String(describing: error))
            }
        }.resume()
    }
    
    //마이 페이지 -> query: user id
    func getMyData(userID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/user/mypage?id=\(userID)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(UserResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.user = result
                    }
                } else {
                    print("no data")
                }
            }catch (let error){
                print("error")
                print(String(describing: error))
            }
        }.resume()
    }
    
    //POST
    //카테고리 추가
    func addNewCategory(newCat: String, userID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/category?id=2") else {
            print("invalid url")
            return
        }
        
        let name = newCat
        let body: [String: Any] = ["name": name]
        let finalData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NewCategoryModel.self, from: data)
                    self.categoryID = result.result?.categoryId ?? 0 //필요한지 모르겠음
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
}
