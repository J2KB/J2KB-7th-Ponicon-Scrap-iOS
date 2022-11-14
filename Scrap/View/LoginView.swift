//
//  ContentView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import KakaoSDKUser

struct LoginView: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var scrapVM : ScrapViewModel
    @State private var id: String = ""
    @State private var pw: String = ""
    @State private var showPW = false //비밀번호 visible, invisible
    @State private var keepLogin = false
    @State private var popRootView = false //LoginView -> MainHome -> MyPage - logout - LoginView
    @State private var movingToSignUp = false
    let message = ["이메일/비밀번호를 입력해주세요", "이메일/비밀번호가 일치하지 않습니다"]
    @State private var messageIndex = -1
    @State private var autoLogin = false
    @State private var isClickedLogin = false
    
    var body: some View {
        NavigationView{
            VStack(spacing: 12){
                VStack(spacing: 10){
                    VStack(spacing: 64){
                        Text("스크랩")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(scheme == .light ? .black : .gray_sub)
                            .multilineTextAlignment(.center)
                            .padding(.top, UIScreen.main.bounds.height / 40)
                        VStack(spacing: 16){ // id/pw textfield
                            TextField("아이디", text: $id)
                                .textInputAutocapitalization(.never) //자동 대문자 비활성화
                                .disableAutocorrection(true) //자동 수정 비활성화
                                .frame(width: UIScreen.main.bounds.width / 1.5 - 24, height: 38)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(scheme == .light ? Color("gray_sub") : .gray_sub)
                                        .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                                )
                            HStack{ //password textfield
                                if showPW {
                                    HStack(spacing: -1){
                                        TextField("비밀번호", text: $pw)
                                            .textInputAutocapitalization(.never) //자동 대문자 비활성화
                                            .disableAutocorrection(true) //자동 수정 비활성화
                                            .frame(width: UIScreen.main.bounds.width / 1.5 - 60, height: 38)
                                        Button(action: {
                                            self.showPW.toggle()
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
                                        SecureField("비밀번호", text: $pw)
                                            .textInputAutocapitalization(.never) //자동 대문자 비활성화
                                            .disableAutocorrection(true) //자동 수정 비활성화
                                            .frame(width: UIScreen.main.bounds.width / 1.5 - 60, height: 38)
                                        Button(action: {
                                            self.showPW.toggle()
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
                        if (!userVM.loginState && isClickedLogin) || messageIndex == 0 { //로그인 실패 -> 에러 메세지
                            Text(message[messageIndex]) //관련 에러 메세지 출력되도록
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
                                        .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                                    Text("자동 로그인")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                                }
                            }else{
                                HStack(spacing: 5){
                                    Image(systemName: "square")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.black_bold)
                                    Text("자동 로그인")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.black_bold)
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.5, height: 12, alignment: .trailing)
                    }
                }
                VStack(spacing: 10){ //Buttons
                    Button(action:{
                        if id.isEmpty || pw.isEmpty { //아이디/비번 비어있으면 입력할 것 toast message 출력
                            messageIndex = 0
                        }else {
                            self.isClickedLogin = true
                            userVM.postLogin(userid: id, password: pw, autoLogin: keepLogin) //📡 LogIn API
                            id = ""
                            pw = ""
                        }
                    }){
                        Text("로그인")
                            .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                            .font(.system(size: 16  , weight: .bold))
                            .foregroundColor(.white)
                            .background(Color("main_accent"))
                            .cornerRadius(12)
                    }
                    NavigationLink("", destination: MainHomeView().navigationBarBackButtonHidden(true).navigationBarHidden(true), isActive: $userVM.loginState)
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
                NavigationLink(destination: SignUpView(movingToSignUp: $movingToSignUp), isActive: $movingToSignUp){
                    Text("회원가입")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray_bold)
                        .underline()
                }
                .padding(.top, 20)
            }
            .background(scheme == .light ? .white : .black_bg)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(/*autoLogin: .constant(true)*/)
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
//            .preferredColorScheme(.dark)
    }
}

//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
//    }
//}
//#endif
