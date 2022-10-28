//
//  UserViewModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/02.
//

import Foundation

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

struct LogOutModel: Decodable{
    let code: Int
    let message: String
    init(code: Int, message: String){
        self.code = code
        self.message = message
    }
}

class UserViewModel: ObservableObject{
//    @Published var login = LoginModel(code: 0, message: "", result: LoginModel.Result(id: 0))
    @Published var loginState = false
//    @Published var signUpState = false
    @Published var loginToastMessage = ""
//    @Published var signupToastMessage = ""
    @Published var userIdx = 0 //initial value
    @Published var iconIdx = 0 //initial value
//    @Published var userID: Int = UserDefaults.standard.integer(forKey: "ID") //user id 없으면 -1

    //POST
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
                    DispatchQueue.main.async {
                        if let response = response as? HTTPURLResponse {
                            if response.statusCode != 200 {
                                self.loginState = false
                                self.loginToastMessage = result.message
                            } else {
                                self.loginState = true
                                self.userIdx = result.result.id //이번 런칭에서 사용할 idx data (일회용)
                                self.iconIdx = Int.random(in: 0...6) //random으로 icon idx 생성하기
                                print("user idx: \(self.userIdx)")
                                if autoLogin { //autoLogin일 때만 저장
                                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(result.result.id, forKey: "ID") //login해서 받은 id를 user defaults에 저장
                                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.iconIdx, forKey: "iconIdx") //login했을 때 생성한 랜덤 icon idx를 user defaults에 저장
                                    print("save user idx, iconIdx to UserDefaults")
                                    print(self.iconIdx)
                                }
                                print("UserDefaults에 저장된 ID 값은? \(UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID"))")
                            }
                        }
                    }
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print("🚨🚨error🚨🚨")
                print(String(describing: error))
            }
        }.resume()
    }
    
    func postKaKaoLogin(accessToken: String, refreshToken: String, autoLogin: Bool){
        print("kakao login")
        guard let url = URL(string: "https://scrap.hana-umc.shop/user/login/kakao/v2") else {
            print("invalid url")
            return
        }

        let accessToken = accessToken
        let refreshToken = refreshToken
        let body: [String: Any] = ["accessToken": accessToken, "refreshToken": refreshToken]
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

                    DispatchQueue.main.async {
                        if let response = response as? HTTPURLResponse {
                            if response.statusCode != 200 {
                                self.loginState = false
                                self.loginToastMessage = result.message
                            } else {
                                self.loginState = true
                                self.userIdx = result.result.id //이번 런칭에서 사용할 idx data (일회용)
                                self.iconIdx = Int.random(in: 0...6) //random으로 icon idx 생성하기
                                print("user idx: \(self.userIdx)")
                                if autoLogin { //autoLogin일 때만 저장
                                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(result.result.id, forKey: "ID") //login해서 받은 id를 user defaults에 저장
                                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.iconIdx, forKey: "iconIdx") //login했을 때 생성한 랜덤 icon idx를 user defaults에 저장
                                    print("save user idx, iconIdx to UserDefaults")
                                    print(self.iconIdx)
                                }
                                print("UserDefaults에 저장된 ID 값은? \(UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID"))")                            }
                        }
                    }
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
//                    DispatchQueue.main.async {
//                        if result.code == 20000 {
//                            self.signUpState = true
//                        } else {
//                            self.signUpState = false
////                            self.signupToastMessage = result.message
//                        }
//                    }
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
    
    //GET
    //로그아웃
    func logOut(){
        guard let url = URL(string: "https://scrap.hana-umc.shop/user/logout") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LogOutModel.self, from: data)
                    print(result)
                    //initialized
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "ID")
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "iconIdx")
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "lastCategory") //모든 자료 카테고리 id로 변경
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
