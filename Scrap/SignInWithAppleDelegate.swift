//
//  SignInWithAppleDelegate.swift
//  Scrap
//
//  Created by 김영선 on 2023/01/05.
//

import SwiftUI
import AuthenticationServices

struct UserData: Codable {
    let email: String
    let name: String
    let identifier: String
}

class SignInWithAppleDelegate: NSObject {
    private let service = APIService()
    private let signInSucceeded: (Bool, LoginModel?) -> Void
    
    init(onSignedIn: @escaping (Bool, LoginModel?) -> Void) {
        signInSucceeded = onSignedIn
    }
}

extension SignInWithAppleDelegate: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential :
            if let _ = appleIDCredential.email, let _ = appleIDCredential.fullName { //최초 로그인
                firstSignInWithApple(credential: appleIDCredential)
            } else {
                signInWithExistingAccount(credential: appleIDCredential)
            }
        default:
            break
        }
    }
    
    func firstSignInWithApple(credential: ASAuthorizationAppleIDCredential) {
        let name = credential.fullName!.familyName! + credential.fullName!.givenName!
        let userData = UserData(email: credential.email!, name: name, identifier: credential.user) //user: identifier for authenticated user
        print(userData)

        //store userData in keychain
        let keychain = Keychain() //create class instance
        if keychain.storeUserData(userData) {
            print("⭐️ success to store userData in keychain")
            print(keychain)
        } else {
            print("🚨 fail to store userData in keychain")
        }
        
        do {
            _ = try postAppleLogin(email: userData.email, name: userData.name, userIdentifier: userData.identifier)//서버 통신
            print("👾 start server networking")
        } catch {
            print("🚨 no server networking")
            self.signInSucceeded(false, nil)
        }
    }
    
    func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) { //이미 한번 등록했었던 계정
        print("☃️ existing account!")
        //keychain에서 name, email, identifier 가져와서 다시 서버 통신
        let keychain = Keychain()
        let userDataInKeyChain = keychain.readUserData()
        print(userDataInKeyChain as Any)
        
        do {
            _ = try postAppleLogin(email: userDataInKeyChain!.email,
                                             name: userDataInKeyChain!.name,
                                             userIdentifier: userDataInKeyChain!.identifier)//서버 통신
            print("👾 start server networking")
        } catch {
            print("🚨 no server networking")
            self.signInSucceeded(false, nil)
        }
    }
    
    //server api method
    func postAppleLogin(email: String, name: String, userIdentifier: String) throws -> Bool {
        print("💡 post apple login")
        
        guard let url = URL(string: "https://scrap.hana-umc.shop/user/login/apple") else {
            print("invalid url")
            return false
        }
        
        let body: [String: Any] = ["userIdentifier": userIdentifier, "name": name, "email": email]
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
                    print("💦 fail to sign in with apple!!")
                    self.signInSucceeded(false, nil)
                case .success(let result):
                    print("👏 success to sign in with apple!!")
                    self.signInSucceeded(true, result)
                    print(result)
                }
            }
        }
        return true
    }
}

extension SignInWithAppleDelegate: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.last!
    }
}
