//
//  ContentView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
//import KakaoSDKUser

struct LoginView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var scrapVM : ScrapViewModel
    @State private var id: String = ""
    @State private var pw: String = ""
    @State private var showPW = false //비밀번호 visible, invisible
    @State private var keepLogin = false
    @State private var popRootView = false
    @State private var movingToSignUp = false
    @State var timeRemaining = 0.01
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    //remove this one, after testing
    @State private var autoLogin = false
    
    let light_gray = Color(red: 217/255, green: 217/255, blue: 217/255)
    let bold_sub_gray = Color(red: 151/255, green: 151/255, blue: 151/255)
    let light_blue = Color(red: 70/255, green: 193/255, blue: 241/255)
    let error_red = Color(red: 255/255, green: 84/255, blue: 84/255)
    
    var body: some View {
        NavigationView{
//            if autoLogin { //자동 로그인의 경우, 바로 HomeView로 이동
//                NavigationLink("", destination: MainHomeView(popRootView: $popRootView).navigationBarBackButtonHidden(true).navigationBarHidden(true), isActive: $popRootView)
//                .onReceive(timer) { _ in
//                    if timeRemaining > 0 {
//                        timeRemaining -= 0.01
//                    }
//                    if timeRemaining == 0 { //0.1 시간 지나면 화면 이동하기
//                        self.popRootView = true
//                    }
//                }
//            }
//            else { //no autoLogin
                VStack{
                    Text("스크랩")
                        .font(.system(size: 64, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 64)
                    VStack(spacing: 32){
                        TextField("아이디", text: $id)
                            .disableAutocorrection(true) //자동 수정 비활성화
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(light_gray)
                                    .frame(height: 40, alignment: .center)
                            )
                        HStack{
                            if showPW {
                                HStack{
                                    TextField("비밀번호", text: $pw)
                                        .disableAutocorrection(true) //자동 수정 비활성화
                                        .padding(.horizontal)
                                        .onSubmit {
                                            hideKeyboard()
                                        }
                                    Button(action: {
                                        self.showPW.toggle()
                                    }) {
                                        Image(systemName: "eye")
                                            .resizable()
                                            .frame(width: 20, height: 13)
                                            .foregroundColor(light_gray)
                                    }
                                    .padding(.trailing, 12)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(light_gray)
                                        .frame(height: 42, alignment: .center)
                                )
                            }
                            else {
                                HStack{
                                    SecureField("비밀번호", text: $pw)
                                        .disableAutocorrection(true) //자동 수정 비활성화
                                        .padding(.horizontal)
                                        .onSubmit {
                                            hideKeyboard()
                                        }
                                    Button(action: {
                                        self.showPW.toggle()
                                    }) {
                                        Image(systemName: "eye.slash")
                                            .resizable()
                                            .frame(width: 20, height: 13)
                                            .foregroundColor(light_gray)
                                    }
                                    .padding(.trailing, 12)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(light_gray)
                                        .frame(height: 42, alignment: .center)
                                )
                            }

                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 15)
                    VStack(){ //로그인 유지 체크 박스
                        if !userVM.loginState {
                            Text(userVM.loginToastMessage) //관련 에러 메세지 따로 출력되도록
                                .font(.caption)
                                .foregroundColor(error_red)
                                .lineLimit(0)
                                .padding(.leading, 4)
                                .frame(width: UIScreen.main.bounds.width - 100, alignment: .leading)
                        }
                        HStack{
                            Button(action: {
                                //stayLogin
                                self.keepLogin.toggle()
                            }) {
                                if keepLogin {
                                    Image(systemName: "checkmark.square")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(light_gray)
                                }else{
                                    Image(systemName: "square")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(light_gray)
                                }
                            }
                            .frame(width: 8, height: 8)
                            Text("자동 로그인")
                                .font(.system(size: 14, weight: .light))
                        }
                        .frame(width: UIScreen.main.bounds.width - 100, alignment: .trailing)
                        .padding(.top, -10)
                    }
                    VStack(spacing: 12){
                        Button(action:{
                            userVM.postLogin(userid: id, password: pw, autoLogin: keepLogin)
                            id = ""
                            pw = ""
                        }){
                            Text("로그인")
                                .frame(width: UIScreen.main.bounds.width-120, height: 28, alignment: .center)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(10)
                                .background(light_blue)
                                .cornerRadius(12)
                        }
                        NavigationLink("", destination: MainHomeView(popRootView: $popRootView).navigationBarBackButtonHidden(true).navigationBarHidden(true), isActive: $userVM.loginState)
                        HStack{
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width/3.1, height: 1)
                                .foregroundColor(light_gray)
                            Text("or")
                                .foregroundColor(light_gray)
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width/3.1, height: 1)
                                .foregroundColor(light_gray)
                        }
                        .padding(.vertical)
                        Button(action: { //kakao login button
//                            if (UserApi.isKakaoTalkLoginAvailable()) {
//                                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
//                                    if let oauthToken = oauthToken {
//                                        userVM.postKaKaoLogin(accessToken: oauthToken.accessToken, refreshToken: oauthToken.refreshToken)
//                                    } else {
//                                        print(String(describing: error))
//                                    }
//                                }
//                            } else {
//                                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
//                                    if let oauthToken = oauthToken {
//                                        userVM.postKaKaoLogin(accessToken: oauthToken.accessToken, refreshToken: oauthToken.refreshToken)
//                                    } else {
//                                        print(String(describing: error))
//                                    }
//                                }
//                            }
                        }) {
                            Image("kakao_login_large_narrow")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width / 1.8, height: 52, alignment: .center)
                        }
                    }
                    NavigationLink(destination: SignUpView(movingToSignUp: $movingToSignUp), isActive: $movingToSignUp){
                        Text("회원가입")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(bold_sub_gray)
                            .underline()
                    }
                    .padding(.top, 12)
                }
                .padding(.bottom, 80)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(ScrapViewModel())
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
#endif
