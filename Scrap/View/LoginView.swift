//
//  ContentView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import KakaoSDKUser

struct LoginView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var scrapVM : ScrapViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false //비밀번호 visible, invisible
    @State private var keepLogin = false
    @State private var goToSignUpView = false
    
    var body: some View {
        //MARK: - iOS 16 이상
        if #available(iOS 16.0, *) {
            NavigationStack{
                VStack(spacing: 12){
                    VStack(spacing: 16){
                        VStack(spacing: 80){
                            Text("스크랩")
                                .font(.system(size: 64, weight: .bold))
                                .foregroundColor(Color("basic_text"))
                                .multilineTextAlignment(.center)
                                .padding(.top, UIScreen.main.bounds.height / 40)
                            VStack(spacing: 16){
                                TextField("이메일", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .frame(width: UIScreen.main.bounds.width / 1.5 - 24, height: 38)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("gray_sub"))
                                            .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                                    )
                                HStack{ //password textfield
                                    if showPassword {
                                        HStack(spacing: -1){
                                            TextField("비밀번호", text: $password)
                                                .textInputAutocapitalization(.never)
                                                .disableAutocorrection(true)
                                                .frame(width: UIScreen.main.bounds.width / 1.5 - 60, height: 38)
                                            Button(action: {
                                                self.showPassword.toggle()
                                            }) {
                                                Image(systemName: "eye")
                                                    .resizable()
                                                    .frame(width: 20, height: 13)
                                                    .foregroundColor(.gray_sub)
                                            }
                                            .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color("gray_sub"))
                                                .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                                        )
                                    }
                                    else {
                                        HStack(spacing: -1){
                                            SecureField("비밀번호", text: $password)
                                                .textInputAutocapitalization(.never)
                                                .disableAutocorrection(true)
                                                .frame(width: UIScreen.main.bounds.width / 1.5 - 60, height: 38)
                                            Button(action: {
                                                self.showPassword.toggle()
                                            }) {
                                                Image(systemName: "eye.slash")
                                                    .resizable()
                                                    .frame(width: 20, height: 13)
                                                    .foregroundColor(.gray_sub)
                                            }
                                            .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color("gray_sub"))
                                                .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                                        )
                                    }
                                }
                            }
                        }
                        VStack(spacing: 4){ //로그인 유지 체크 박스
                            if !userVM.loginState { //로그인 실패 -> 에러 메세지
                                Text(userVM.loginToastMessage) //관련 에러 메세지 출력되도록
                                    .font(.caption)
                                    .foregroundColor(.red_error)
                                    .lineLimit(1)
                                    .padding(.leading, 4)
                                    .frame(width: UIScreen.main.bounds.width / 1.5, height: 10, alignment: .leading)
                            }
                            Button(action: { //자동 로그인 체크박스 버튼
                                self.keepLogin.toggle()
                            }) {
                                if keepLogin {
                                    HStack(spacing: 5){
                                        Image(systemName: "checkmark.square.fill")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color("basic_text"))
                                        Text("자동 로그인")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Color("basic_text"))
                                    }
                                }else{
                                    HStack(spacing: 5){
                                        Image(systemName: "square")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color("basic_text"))
                                        Text("자동 로그인")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(Color("basic_text"))
                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 1.5, height: 12, alignment: .trailing)
                        }
                    }
                    VStack(spacing: 10){ //Buttons
                        Button(action:{
                            userVM.postLogin(email: email, password: password, autoLogin: keepLogin) //📡 LogIn API
                            email = ""
                            password = ""
                        }){
                            Text("로그인")
                                .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                                .font(.system(size: 16  , weight: .bold))
                                .foregroundColor(.white)
                                .background(Color("main_accent"))
                                .cornerRadius(12)
                        }
                        HStack{
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width/3.5, height: 1)
                                .foregroundColor(.gray_sub)
                            Spacer()
                            Text("or")
                                .foregroundColor(.gray_sub)
                                .font(.system(size: 12))
                            Spacer()
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width/3.5, height: 1)
                                .foregroundColor(.gray_sub)
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.5)
                        .padding(.bottom, 10)
                        Button(action: { //kakao login button
                            if (UserApi.isKakaoTalkLoginAvailable()) {
                                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                                    if let oauthToken = oauthToken {
                                        userVM.postKaKaoLogin(accessToken: oauthToken.accessToken, refreshToken: oauthToken.refreshToken, autoLogin: keepLogin)
                                    } else {
                                        print(String(describing: error))
                                    }
                                }
                            } else {
                                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                                    if let oauthToken = oauthToken {
                                        userVM.postKaKaoLogin(accessToken: oauthToken.accessToken, refreshToken: oauthToken.refreshToken, autoLogin: keepLogin)
                                    } else {
                                        print(String(describing: error))
                                    }
                                }
                            }
                        }) {
                            Image("kakao_login_large_narrow")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width / 1.8, height: 52, alignment: .center)
                        }
                    }
                    Button(action: {
                        self.goToSignUpView = true
                    }, label: {
                        Text("회원가입")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray_bold)
                            .underline()
                    })
                    .padding(.top, 20)
                }
                .navigationDestination(isPresented: $userVM.loginState) {
                    MainHomeView().navigationBarBackButtonHidden(true).navigationBarHidden(true)
                }
                .navigationDestination(isPresented: $goToSignUpView) {
                    SignUpView(goToSignUpView: $goToSignUpView)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
            }
        } else {
            LoginViewDeprecated()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
