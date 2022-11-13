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
    @State private var id: String = ""
    @State private var pw: String = ""
    @State private var showPW = false //비밀번호 visible, invisible
    @State private var keepLogin = false
    @State private var popRootView = false //LoginView -> MainHome -> MyPage - logout - LoginView
    @State private var movingToSignUp = false
    @State var timeRemaining = 0.01
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var autoLogin = false
    let userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID")

    var body: some View {
        NavigationView{
            if /*autoLogin*/userIdx != 0 { //자동 로그인의 경우, 바로 HomeView로 이동
                NavigationLink("", destination: MainHomeView(popRootView: $popRootView, autoLogin: $autoLogin).navigationBarBackButtonHidden(true).navigationBarHidden(true), isActive: $popRootView)
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 0.01
                    }
                    if timeRemaining == 0 { //0.1 시간 지나면 화면 이동하기
                        self.popRootView = true
                    }
                }
            }
            else { //no autoLogin
                VStack{
                    VStack(spacing: 8){
                        VStack(spacing: 64){
                            Text("스크랩")
                                .font(.system(size: 64, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.top, UIScreen.main.bounds.height / 40)
                            VStack(spacing: 16){ // id/pw textfield
                                TextField("아이디", text: $id)
                                    .disableAutocorrection(true) //자동 수정 비활성화
                                    .frame(width: UIScreen.main.bounds.width / 1.5 - 24, height: 38)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("gray_sub"))
                                            .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                                    )
                                    .onSubmit { //return 누르면 키보드 사라짐
                                        hideKeyboard()
                                    }
                                HStack{ //password textfield
                                    if showPW {
                                        HStack(spacing: -1){
                                            TextField("비밀번호", text: $pw)
                                                .disableAutocorrection(true) //자동 수정 비활성화
                                                .frame(width: UIScreen.main.bounds.width / 1.5 - 60, height: 38)
                                                .onSubmit { //return 누르면 키보드 사라짐
                                                    hideKeyboard()
                                                }
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
                                                .disableAutocorrection(true) //자동 수정 비활성화
                                                .frame(width: UIScreen.main.bounds.width / 1.5 - 60, height: 38)
                                                .onSubmit {
                                                    hideKeyboard()
                                                }
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
                            if !userVM.loginState { //로그인 실패 -> 에러 메세지
                                Text(userVM.loginToastMessage) //관련 에러 메세지 출력되도록
                                    .font(.caption)
                                    .foregroundColor(.red_error)
                                    .lineLimit(1)
                                    .padding(.leading, 4)
                                    .frame(width: UIScreen.main.bounds.width / 1.5, height: 10, alignment: .leading)
                            }
                            HStack(spacing: 4){ //자동 로그인 체크박스 버튼
                                Button(action: {
                                    self.keepLogin.toggle()
                                }) {
                                    if keepLogin {
                                        Image(systemName: "checkmark.square.fill")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.black_bold)
                                    }else{
                                        Image(systemName: "square")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.gray_bold)
                                    }
                                }
                                Text("자동 로그인")
                                    .font(.system(size: 12, weight: .regular))
                            }
                            .frame(width: UIScreen.main.bounds.width / 1.5, height: 12, alignment: .trailing)
                        }
                    }
                    VStack(spacing: 10){ //Buttons
                        Button(action:{
                            userVM.postLogin(userid: id, password: pw, autoLogin: keepLogin) //📡 LogIn API
                            id = ""
                            pw = ""
                        }){
                            Text("로그인")
                                .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                                .font(.system(size: 16  , weight: .bold))
                                .foregroundColor(.white)
                                .background(Color("main_accent"))
                                .cornerRadius(12)
                        }
                        NavigationLink("", destination: MainHomeView(popRootView: $popRootView, autoLogin: $autoLogin).navigationBarBackButtonHidden(true).navigationBarHidden(true), isActive: $userVM.loginState)
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
            }
        }
        .onAppear {
            print("Login View")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(/*autoLogin: .constant(true)*/)
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
#endif
