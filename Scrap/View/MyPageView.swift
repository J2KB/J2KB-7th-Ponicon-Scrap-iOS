//
//  MyPageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct MyPageView: View {
    @Binding var userData : UserResponse.Result
    @State private var isEditingUserName = false
    @State private var username = ""
    @State private var iconArr = ["camping", "circus", "classical", "compass", "palette", "rocket", "ufo"]
//    @Binding var popRootView : Bool
    @Binding var isShowingMyPage : Bool
    @EnvironmentObject var vm : UserViewModel //여기서 로그아웃
//    @Binding var autoLogin : Bool
    @Environment(\.presentationMode) var presentationMode //pop sheet
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40){
                VStack{
                    HStack(spacing: 10){
    //                    Image("\(iconArr[vm.iconIdx])") //랜덤 출력 <- 에러
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 70, height: 70)
                        VStack(spacing: 8){
                            Text("\(userData.name) 님") //user data 가져오기
                                .lineLimit(2)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(scheme == .light ? .black : .gray_sub)
                                .frame(width: UIScreen.main.bounds.width / 1.5, height: 30, alignment: .leading)
                            Text("\(userData.username)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray_bold)
                                .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.5, height: 70, alignment: .leading)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    Divider()
                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .center)
                        .padding(.top, 20)
                    Spacer()
                    Button(action:{
                        print("log out")
                        vm.logOut() //📡 LogOut API
//                        autoLogin = false
//                        print(autoLogin)
//                        popRootView = false //NavigationLink로 LoginView로 이동
//                        print(popRootView)
                        vm.loginState = false //NavigationLink로 LoginView로 이동
                        print(vm.loginState)
                        vm.userIdx = 0
                        UserDefaults(suiteName: "group.com.thk.Scrap")?.set(0, forKey: "ID")
                        print(vm.userIdx)
                        isShowingMyPage = true
                        print(isShowingMyPage)
                        //데이터 지우기 -> user id 데이터 지우기
                    }){
                        Text("로그아웃")
                            .underline()
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray_bold)
                    }
                }//VStack2
            }//VStack1
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
                                .foregroundColor(scheme == .light ? .black : .gray_sub)
                        }
                        Text("마이페이지")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 100, height: 20, alignment: .leading)
                            .foregroundColor(scheme == .light ? .black : .gray_sub)
                    }
                }
            }
            .background(scheme == .light ? .white : .black_bg)
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(userData: .constant(UserResponse.Result(name: "", username: "")), isShowingMyPage: .constant(true))
            .environmentObject(ScrapViewModel())
            .preferredColorScheme(.dark)
    }
}
