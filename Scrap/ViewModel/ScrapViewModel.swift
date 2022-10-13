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
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)]))  //초기화
    //categoryList에는 Category 값만 넣을 것..!
    @Published var dataList = DataResponse(code: 0, message: "", result: DataResponse.Result(links: [DataResponse.Datas(linkId: 0, link: "", title: "", imgUrl: "")]))
    @Published var user = UserResponse(code: 0, message: "", result: UserResponse.Result(name: "", username: ""))
    
    var failLogin = false
    var failedLoginToastMessage = ""
    var categoryID = 0
    
    func appendCategory(newCategory: CategoryResponse.Category){
        categoryList.result.categories.append(newCategory)
    }
    
    //GET
    //카테고리 전체 조회
    func getCategoryData(userID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/category/all?id=\(userID)") else {
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
        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=\(userID)&category=\(catID)&seq=\(seq)") else {
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
        guard let url = URL(string: "https://scrap.hana-umc.shop/user/mypage?id=\(userID)") else {
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
        guard let url = URL(string: "https://scrap.hana-umc.shop/category?id=2") else {
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
                    self.categoryID = result.result?.categoryId ?? 0
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
    
//    //자료 저장
//    func addNewData(userID: Int, ){
//        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=2&category=3") else {
//            print("invalid url")
//            return
//        }
//
//        let baseURL = "https://msearch.shopping.naver.com/book/catalog/32490794178?query=%EC%84%9C%EC%9A%B8%EC%8B%9C&NaPm=ct%3Dl8n3zly0%7Cci%3Da2b61e45d04a07004ebfbf8c0f18f65b73892fe8%7Ctr%3Dboksl%7Csn%3D95694%7Chk%3D6e1701f1592ca7e85c1ed5444d4302ff63462f28"
//
//        let body: [String: Any] = ["baseURL":baseURL]
//        let finalData = try! JSONSerialization.data(withJSONObject: body)
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = finalData
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            do{
//                if let data = data {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(NewDataModel.self, from: data)
//                    print(result)
//                } else {
//                    print("no data")
//                }
//            }catch (let error){
//                print("error")
//                print(String(describing: error))
//            }
//        }.resume()
//    }
}
