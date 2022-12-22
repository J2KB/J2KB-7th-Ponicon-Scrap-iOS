//
//  MyPageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import KakaoSDKUser

struct MyPageView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM : UserViewModel
    @State private var iconList = ["camping", "circus", "classical", "compass", "palette", "rocket", "ufo"]

    @Binding var userData : UserResponse.Result
    @Binding var isShowingMyPage : Bool
    
    var isKakaoLogin : Bool {
        return !userData.username.contains(where: {$0.isLetter})
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40){
                VStack{
                    HStack(spacing: 10){
                        Image("\(iconList[userVM.iconIdx])") //랜덤 출력 <- 에러
                            .resizable()
                            .frame(width: 70, height: 70)
                        VStack(spacing: 8){
                            Text("\(userData.name) 님") //user data 가져오기
                                .lineLimit(2)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("basic_text"))
                                .frame(width: UIScreen.main.bounds.width / 1.5, height: 30, alignment: .leading)
                            Text(isKakaoLogin ? "" : "\(userData.username)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray_bold)
                                .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.5, height: 70, alignment: .leading)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    Divider()
                        .overlay(Color("gray_bold"))
                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .center)
                        .padding(.top, 20)
                    Spacer()
                    Button(action:{
                        if isKakaoLogin {
                            UserApi.shared.logout {(error) in
                                if let error = error { print(error) }
                                else { print("logout() success.") }
                            }
                        }
                        print("log out")
                        userVM.logOut() //📡 LogOut API
                        userVM.loginState = false
                        print(userVM.loginState)
                        userVM.userIndex = 0
                        UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "ID")
                        print(userVM.userIndex)
                        isShowingMyPage = true
                        print(isShowingMyPage)
                        //데이터 지우기 -> user id 데이터 지우기
                    }){
                        Text("로그아웃")
                            .underline()
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.gray_bold)
                    }
                    .padding(.bottom, 20)
                }//VStack2
            }//VStack1
            .padding(.top, 24)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    HStack(spacing: 8){
                        Button(action: {
                            withAnimation(.easeInOut.delay(0.3)){
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .frame(width: 10, height: 16)
                                .foregroundColor(Color("basic_text"))
                        }
                        Text("마이페이지")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 100, height: 20, alignment: .leading)
                            .foregroundColor(Color("basic_text"))
                    }
                }
            }
        }
        .gesture(DragGesture().onEnded({
            if $0.translation.width > 100 {
                withAnimation(.easeInOut) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }))
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(userData: .constant(UserResponse.Result(name: "", username: "")), isShowingMyPage: .constant(true))
            .environmentObject(ScrapViewModel())
    }
}
