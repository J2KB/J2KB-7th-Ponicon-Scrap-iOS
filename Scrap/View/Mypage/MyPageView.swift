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
    @State private var iconList = ["tiger", "dog", "cat", "fox", "mouse", "rabbit", "bear"]
    @State private var reallyWithDrawal = false
    
    @Binding var userData : UserResponse.Result
    @Binding var isShowingMyPage : Bool
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        NavigationView{
            VStack {
                //Profile
                VStack{
                    HStack(spacing: 10){
                        Image("\(iconList[userVM.iconIdx])")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .padding(.leading, 16)
                        VStack(spacing: 4){
                            Text("\(userData.name) 님") //user data 가져오기
                                .lineLimit(2)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("basic_text"))
                                .frame(width: screenWidth / 1.5, height: 40, alignment: .bottomLeading)
                            Text(userVM.loginType != .email ? "" : "\(userData.username)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray_bold)
                                .frame(width: screenWidth / 1.5, alignment: .leading)
                        }
                        Spacer()
                    }
                    .frame(width: screenWidth / 1.13, height: screenHeight / 9)
                    Divider()
                        .frame(width: screenWidth / 1.13, alignment: .center)
                        .overlay(Color("gray_bold"))
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
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Text("로그아웃")
                            .font(.system(size: 14, weight: .semibold))
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
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray_bold)
                            .frame(width: screenWidth, height: 32, alignment: .leading)
                    }
                    .padding(.leading, screenWidth / 8)
                    Divider()
                        .overlay(Color("gray_bold"))
                        .frame(width: screenWidth / 1.13, alignment: .center)
                }//VStack2
                Spacer()
                    .frame(height: UIScreen.main.bounds.height / 1.7)
            }//VStack1
        }
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
        .alert("회원 탈퇴하시겠습니까?", isPresented: $reallyWithDrawal, actions: {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                userVM.acccountWithdrawal() //📡 WithDrawal API
                userVM.loginState = false
                userVM.userIndex = 0
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .gesture(DragGesture().onEnded({
            if $0.translation.width > 100 {
                withAnimation(.easeInOut) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
         }))

    }
}
