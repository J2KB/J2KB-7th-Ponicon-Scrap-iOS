//
//  ScrapViewModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/29.
//

import Foundation

struct NewCategoryModel: Decodable{
    struct Result: Decodable {
        var id: Int
        
        init(id: Int){
            self.id = id
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

struct NewDataModel: Decodable{
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

struct LoginModel: Decodable{
    struct Result: Decodable {
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

struct SignUpModel: Decodable{
    var code: Int
    var message: String
    
    init(code: Int, message: String){
        self.code = code
        self.message = message
    }
}

class ScrapViewModel: ObservableObject{
    //Get Objects
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)])) { //초기화
        willSet{
            objectWillChange.send()
        }
    }
    //categoryList에는 Category 값만 넣을 것..!
    @Published var dataList = DataResponse(code: 0, message: "", result: DataResponse.Result(links: [DataResponse.Datas(linkId: 0, link: "", title: "", imgUrl: "")]))
    @Published var user = UserResponse(code: 0, message: "", result: UserResponse.Result(name: "", username: ""))
    //Post Objects
    @Published var login = LoginModel(code: 0, message: "", result: LoginModel.Result(id: 0))
    
    var successLogin = false
    
    //GET
    //카테고리 전체 조회
    func getCategoryData(){
        guard let url = URL(string: "https://scrap.hana-umc.shop/category/all?id=2") else {
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
    func getData(catID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=2&category=\(catID)&seq=desc") else {
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
    
    //로그아웃
//    func get(userID: Int){
//        guard let url = URL(string: "https://scrap.hana-umc.shop/user/mypage?id=\(userID)") else {
//            print("invalid url")
//            return
//        }
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            do{
//                if let data = data {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(UserResponse.self, from: data)
//                    DispatchQueue.main.async {
//                        self.user = result
//                    }
//                } else {
//                    print("no data")
//                }
//            }catch (let error){
//                print("error")
//                print(String(describing: error))
//            }
//        }.resume()
//    }
    
    
    //POST
    //카테고리 추가
    func addNewCategory(newCat: String){
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
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
    
    //로그인
    func postLogin(userid: String, password: String, autoLogin: Bool){
        guard let url = URL(string: "https://scrap.hana-umc.shop/user/login") else {
            print("invalid url")
            return
        }
        
        let id = userid
        let pw = password
        let autoLogin = autoLogin
        let body: [String: Any] = ["username": id, "password": pw, "autoLogin": autoLogin]
        let finalData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LoginModel.self, from: data)
                    self.successLogin = true
                    print("success posting login data")
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print("erorr")
                self.successLogin = false
                print(String(describing: error))
            }
        }.resume()
    }
    
    //회원가입
    func postSignUp(userid: String, password: String, name: String){
        guard let url = URL(string: "https://scrap.hana-umc.shop/user/join") else {
            print("invalid url")
            return
        }

        let username = userid
        let pw = password
        let name = name
        let body: [String: Any] = ["username": username, "password": pw, "name": name]
        let finalData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SignUpModel.self, from: data)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
    
    //자료 저장
    func addNewData(){
        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=2&category=3") else {
            print("invalid url")
            return
        }

        let baseURL = "https://www.apple.com"
        
        let body: [String: Any] = ["baseURL":baseURL]
        let finalData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NewDataModel.self, from: data)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print("error")
                print(String(describing: error))
            }
        }.resume()
    }
}
