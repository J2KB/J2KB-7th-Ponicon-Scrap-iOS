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

struct CheckDuplication: Decodable{
    struct Result: Decodable {
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

struct FailModel: Decodable {
    let code: Int
    let message: String
}

class UserViewModel: ObservableObject{
    @Published var loginState = false               //로그인 상태 변수
    @Published var loginToastMessage = ""
    @Published var userIdx = 0 //initial value      //사용자 idx
    @Published var iconIdx = 0 //initial value      //사용자 아이콘 idx
    @Published var duplicateMessage = 4            //이메일 중복 상태 변수
    
    private let baseUrl = "https://scrap.hana-umc.shop/user"
    
    private let decoder = JSONDecoder()
    
    //=========POST=========
    //로그인
    //body: userid/pw/autoLogin
    func postLogin(email: String, password: String, autoLogin: Bool){
        guard let url = URL(string: "\(baseUrl)/login") else {
            print("invalid url")
            return
        }
        
        let email = email
        let pw = password
        let autoLogin = autoLogin
        let body: [String: Any] = ["email": email, "password": pw, "autoLogin": autoLogin]
        let finalData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    guard let httpResponse = response as? HTTPURLResponse else {return}
                    if httpResponse.statusCode != 200 { //로그인 실패
                        self.loginState = false
                        do{
                            let failMessage = try self.decoder.decode(FailModel.self, from: data)
                            print(failMessage)
                            if failMessage.code == 2001 {
                                self.loginToastMessage = "이메일/비밀번호는 필수값입니다"
                            } else if failMessage.code == 3003 {
                                self.loginToastMessage = "해당하는 이메일/비밀번호가 없습니다"
                            }
                        } catch let error {
                            print("error")
                            print(String(describing: error))
                        }
                    } else { //로그인 성공
                        do {
                            let result = try self.decoder.decode(LoginModel.self, from: data)
                            print(result)
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
                            print("UserDefaults에 저장된 ID 값은? \(UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") ?? 0)")
                        } catch let error {
                            print("error")
                            print(String(describing: error))
                        }
                    }
                }
            }
//            do{
//                if let data = data {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(LoginModel.self, from: data)
//                    DispatchQueue.main.async {
//                        if let response = response as? HTTPURLResponse {
//                            if response.statusCode != 200 { //통신 실패 시
//                                self.loginState = false
//                                self.loginToastMessage = result.message
//                            } else {                        //통신 성공 시
//                                self.loginState = true
//                                self.userIdx = result.result.id //이번 런칭에서 사용할 idx data (일회용)
//                                self.iconIdx = Int.random(in: 0...6) //random으로 icon idx 생성하기
//                                print("user idx: \(self.userIdx)")
//                                if autoLogin { //autoLogin일 때만 저장
//                                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(result.result.id, forKey: "ID") //login해서 받은 id를 user defaults에 저장
//                                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.iconIdx, forKey: "iconIdx") //login했을 때 생성한 랜덤 icon idx를 user defaults에 저장
//                                    print("save user idx, iconIdx to UserDefaults")
//                                    print(self.iconIdx)
//                                }
//                                print("UserDefaults에 저장된 ID 값은? \(UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") ?? 0)")
//                            }
//                        }
//                    }
//                    print(result)
//                } else {
//                    print("no data")
//                }
//            }catch (let error){
//                print("🚨🚨error🚨🚨")
//                print(String(describing: error))
//            }
        }.resume()
    }
    
    //카카오로그인
    //body: accessToken/refreshToken/autoLogin
    func postKaKaoLogin(accessToken: String, refreshToken: String, autoLogin: Bool){
        print("kakao login")
        guard let url = URL(string: "\(baseUrl)/login/kakao/v2") else {
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
            DispatchQueue.main.async {
                if let data = data {
                    let decoder = JSONDecoder()
                    guard let httpResponse = response as? HTTPURLResponse else {return}
                    if httpResponse.statusCode != 200 { //카카오 로그인(리디렉션) 실패
                        self.loginState = false
                        do{
                            print("Kakao Login")
                            let failMessage = try self.decoder.decode(NoResultModel.self, from: data)
                            print(failMessage)
                        } catch let error {
                            print("error")
                            print(String(describing: error))
                        }
                    }else {
                        do{
                            let result = try decoder.decode(LoginModel.self, from: data)
                            //카카오로 로그인 -> accessToken/refreshToken 모두 받아와서 POST하면 서버로부터 사용자의 ID를 받음.
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
                            print("UserDefaults에 저장된 ID 값은? \(UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") ?? 0)")
                            print(result)
                        }catch (let error){
                            print("error")
                            print(String(describing: error))
                        }
                    }
                }
            }
        }.resume()
    }
    
    //회원가입
    //body: email/pw/name
    func postSignUp(email: String, password: String, name: String){
        guard let url = URL(string: "\(baseUrl)/join") else {
            print("invalid url")
            return
        }
        let email = email
        let pw = password
        let name = name
        let body: [String: Any] = ["email": email, "password": pw, "name": name]
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
    
    //=========GET=========
    //로그아웃
    func logOut(){
        guard let url = URL(string: "\(baseUrl)/logout") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LogOutModel.self, from: data)
                    DispatchQueue.main.async {
                        //initialized
                        //모든 자료 카테고리 id로 변경
                        UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "ID")
                        self.userIdx = 0
                        UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "iconIdx")
                        self.iconIdx = 0
                        UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "lastCategory")
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
    
    //이메일 중복확인
    //query: email
    
    func checkDuplication(email: String){
        guard let url = URL(string: "\(baseUrl)/duplicate?id=\(email)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    guard let httpResponse = response as? HTTPURLResponse else {return}
                    if httpResponse.statusCode != 200 {
                        do {
                            let decoder = JSONDecoder()
                            let fail = try decoder.decode(FailModel.self, from: data)
                            print(fail)
                        } catch let error {
                            print("🚨error")
                            print(String(describing: error))
                        }
                    }else{
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(CheckDuplication.self, from: data)
                            self.duplicateMessage = result.result.isDuplicate ? 11 : 4
                            print(result)
                        } catch let error {
                            print("🚨🚨error")
                            print(String(describing: error))
                        }
                    }
                }
            }
        }.resume()
    }
}


