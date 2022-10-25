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
    @Binding var popRootView : Bool
    @EnvironmentObject var vm : UserViewModel //여기서 로그아웃
    @Environment(\.presentationMode) var presentationMode //pop sheet
    
    var body: some View {
        VStack(spacing: 40){
            HStack{
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 12, height: 16)
                        .foregroundColor(.black)
                }
                Text("마이페이지")
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(width: UIScreen.main.bounds.width-20, alignment: .leading)
            VStack{
                HStack(spacing: 8){
                    Image("\(iconArr[vm.iconIdx])") //랜덤 출력
                        .resizable()
                        .frame(width: 70, height: 70)
                    VStack(spacing: 10){
                        Text("\(userData.name) 님") //user data 가져오기
                            .lineLimit(2)
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: UIScreen.main.bounds.width / 1.5, height: 28, alignment: .leading)
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
                    .padding(.top, 12)
                Spacer()
                Button(action:{
                    vm.logOut() //logout 서버에 보내기
                    popRootView = false                     //NavigationLink로 LoginView로 이동
                    vm.loginState = false
                    //데이터 지우기 -> user id 데이터 지우기
                    print("log out")
                    print(vm.userIdx)
                }){
                    Text("로그아웃")
                        .underline()
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray_bold)
                }
            }//VStack2
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }//VStack1
        .frame(height: UIScreen.main.bounds.height - 100, alignment: .top)
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(userData: .constant(UserResponse.Result(name: "", username: "")), popRootView: .constant(true))
            .environmentObject(ScrapViewModel())
    }
}
