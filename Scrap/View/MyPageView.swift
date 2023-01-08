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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40){
                VStack{
                    HStack(spacing: 10){
                        Image("\(iconList[userVM.iconIdx])")
                            .resizable()
                            .frame(width: 70, height: 70)
                        VStack(spacing: 8){
                            Text("\(userData.name) 님") //user data 가져오기
                                .lineLimit(2)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("basic_text"))
                                .frame(width: UIScreen.main.bounds.width / 1.5, height: 30, alignment: .leading)
                            Text(userVM.loginType != .email ? "" : "\(userData.username)")
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
                    HStack(spacing: 10) {
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
                            isShowingMyPage = true
                        }){
                            Text("로그아웃")
                                .underline()
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray_bold)
                        }
                        Divider()
                            .overlay(.black)
                            .frame(height: 16)
                        Button(action:{
                            self.reallyWithDrawal = true
                        }){
                            Text("회원탈퇴")
                                .underline()
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray_bold)
                        }
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
        .alert("회원 탈퇴하시겠습니까?", isPresented: $reallyWithDrawal, actions: {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                userVM.acccountWithdrawal() //📡 WithDrawal API
                userVM.loginState = false
                userVM.userIndex = 0
                isShowingMyPage = true
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

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(userData: .constant(UserResponse.Result(name: "", username: "")), isShowingMyPage: .constant(true))
            .environmentObject(ScrapViewModel())
    }
}
