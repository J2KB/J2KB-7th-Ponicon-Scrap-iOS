//
//  MyPageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import KakaoSDKUser

struct MyPageView: View {
//    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM : UserViewModel
    @State private var iconList = ["tiger", "dog", "cat", "fox", "mouse", "rabbit", "bear"]
    @State private var reallyWithDrawal = false
    
    @Binding var userData : UserResponse.Result
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
            VStack {
                Text("마이페이지")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: screenWidth, height: 40, alignment: .leading)
                    .foregroundColor(Color("basic_text"))
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0)) //superview
//                    .background(.green)
                VStack{
                    HStack(spacing: 10){
//                        Image("\(iconList[userVM.iconIdx])")
                        Image("\(iconList[5])")
                            .resizable()
                            .frame(width: 70, height: 70)
//                            .background(.blue)
                            .padding(.leading, 16)
                        VStack(spacing: 4){
//                            Text("\(userData.name) 님") //user data 가져오기
                            Text("녕이 님")
                                .lineLimit(2)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("basic_text"))
                                .frame(width: screenWidth / 1.5, height: 40, alignment: .bottomLeading)
//                                .background(.red)
//                            Text(userVM.loginType != .email ? "" : "\(userData.username)")
                            Text("nyeong1030@comcomcom")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray_bold)
                                .frame(width: screenWidth / 1.5, alignment: .leading)
//                                .background(.yellow)
                        }
//                        .background(.cyan)
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width)
//                    .background(.gray)
                    Divider()
                        .frame(height: 4)
                        .frame(width: screenWidth / 1.13, alignment: .center)
                        .overlay(Color("gray_sub"))
                        .padding(.top, 4)
                    Button(action:{
                        if userVM.loginType == .kakao {
                            UserApi.shared.logout {(error) in
                                if let error = error { print(error) }
                                else { print("logout() success.") }
                            }
                        }
                        userVM.logOut() //📡 LogOut API
                        userVM.loginState = false
                        userVM.userIndex = 0
                        UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "ID")
//                            isShowingMyPage = true
                    }){
                        Text("로그아웃")
                            .underline()
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray_bold)
                            .frame(width: screenWidth, height: 32, alignment: .leading)
                    }
                    .padding(.leading, screenWidth / 8)
                    .padding(.top, 4)
                    Divider()
                        .overlay(Color("gray_bold"))
                        .frame(width: screenWidth / 1.13, alignment: .center)
                    Button(action:{
                        self.reallyWithDrawal = true
                    }){
                        Text("회원탈퇴")
                            .underline()
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray_bold)
                            .frame(width: screenWidth, height: 32, alignment: .leading)
                    }
                    .padding(.leading, screenWidth / 8)
                    Divider()
                        .overlay(Color("gray_bold"))
                        .frame(width: screenWidth / 1.13, alignment: .center)
                }//VStack2
                Spacer()
            }//VStack1
            .padding(.top, 24)
        
        .alert("회원 탈퇴하시겠습니까?", isPresented: $reallyWithDrawal, actions: {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                userVM.acccountWithdrawal() //📡 WithDrawal API
                userVM.loginState = false
                userVM.userIndex = 0
//                isShowingMyPage = true
            }
        })
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(userData: .constant(UserResponse.Result(name: "", username: "")))
            .environmentObject(UserViewModel())
    }
}
