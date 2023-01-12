//
//  UserViewModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/02.
//

import Foundation
import AuthenticationServices

enum LoginType {
    case email, kakao, apple, none
}

class UserViewModel: ObservableObject{
    @Published var appleSignInDelegate: SignInWithAppleDelegate! = nil
    @Published var loginState = false               //로그인 상태 변수
    @Published var loginToastMessage = ""
    @Published var userIndex = 0                    //initial value    //사용자 idx
    @Published var iconIdx = 0                      //initial value    //사용자 아이콘 idx
    @Published var duplicateMessage = 9             //이메일 중복 상태 변수
    @Published var loginType = LoginType.none
    private let service = APIService()
    private let baseUrl = "https://scrap.hana-umc.shop/user"
    private let decoder = JSONDecoder()
    
    // MARK: 로그인
    func postLogin(email: String, password: String){
        guard let url = URL(string: "\(baseUrl)/login") else {
            print("invalid url")
            return
        }
        
        let email = email
        let pw = password
        let body: [String: Any] = ["email": email, "password": pw, "autoLogin": true]
        let finalData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    guard let httpResponse = response as? HTTPURLResponse else { return }
                    if httpResponse.statusCode != 200 { //로그인 실패
                        do{
                            let failMessage = try self.decoder.decode(FailModel.self, from: data)
                            print(failMessage)
                            self.loginState = false
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
                            self.userIndex = result.result.id //이번 런칭에서 사용할 idx data (일회용)
                            self.iconIdx = Int.random(in: 0...6) //random으로 icon idx 생성하기
                            self.loginType = .email
                            UserDefaults(suiteName: "group.com.thk.Scrap")?.set(result.result.id, forKey: "ID")
                            UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.iconIdx, forKey: "iconIdx")
                        } catch let error {
                            print("error")
                            print(String(describing: error))
                        }
                    }
                }
            }
        }.resume()
    }
    
    
    // MARK: 카카오 로그인
    func postKaKaoLogin(accessToken: String, refreshToken: String){
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
        
        service.requestTask(LoginModel.self, withRequest: request) { [unowned self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                    self.loginState = false
                case .success(let result):
                    self.userIndex = result.result.id //이번 런칭에서 사용할 idx data (일회용)
                    self.iconIdx = Int.random(in: 0...6) //random으로 icon idx 생성하기
                    self.loginState = true
                    self.loginType = .kakao
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.userIndex, forKey: "ID")
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.iconIdx, forKey: "iconIdx")
                    print(result)
                }
            }
        }
    }
    
    // MARK: - 애플 로그인
    func appleLogin(){
        appleSignInDelegate = SignInWithAppleDelegate { (success, result) in
            print("로그인 성공? : \(success)")
            guard result != nil else {
                print("no result in applesignindelegate")
                return
            } //result == nil이면 끗
            if success { //update UI --> MainHomeView로 화면 전환!
                self.userIndex = result!.result.id //이번 런칭에서 사용할 idx data (일회용)
                self.iconIdx = Int.random(in: 0...6) //random으로 icon idx 생성하기
                self.loginState = true
                self.loginType = .apple
                UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.userIndex, forKey: "ID")
                UserDefaults(suiteName: "group.com.thk.Scrap")?.set(self.iconIdx, forKey: "iconIdx")
            } else {
                self.loginState = false
            }
        }
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email] //필요한 사용자 데이터
        let controller = ASAuthorizationController(authorizationRequests: [request]) //sign in dialog에 표시할 controller
        controller.delegate = appleSignInDelegate
        controller.presentationContextProvider = appleSignInDelegate
        controller.performRequests()
    }
    
    // MARK: 회원가입
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
        
        service.requestTask(SignUpModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                }
            }
        }
    }
    
    // MARK: 로그아웃
    func logOut(){
        guard let url = URL(string: "\(baseUrl)/logout") else {
            print("invalid url")
            return
        }
        service.fetchData(SignUpModel.self, baseUrl: url, completionHandler: { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(_):
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "ID")
                    self.userIndex = 0
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "iconIdx")
                    self.iconIdx = 0
                }
            }
        })
    }
    
    // MARK: 회원탈퇴
    func acccountWithdrawal(){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/user/\(userIndex)") else {
            print("invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        service.requestTask(NoResultModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "ID")
                    self.userIndex = 0
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "iconIdx")
                    self.iconIdx = 0
                    print(result)
                }
            }
        }
    }
    
    // MARK: 이메일 중복 확인
    func checkDuplication(email: String) {
        guard let url = URL(string: "\(baseUrl)/duplicate?id=\(email)") else {
            print("invalid url")
            return
        }
        service.fetchData(CheckDuplication.self, baseUrl: url, completionHandler: { [unowned self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.duplicateMessage = result.result.isDuplicate ? 4 : 10
                    print(result)
                }
            }
        })
    }
}
