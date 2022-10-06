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
    @Binding var autoLogin : Bool
    @EnvironmentObject var vm : UserViewModel //여기서 로그아웃
    @Environment(\.presentationMode) var presentationMode //pop sheet
    
    let icon = Int.random(in: 0...6)
    
    var body: some View {
        VStack(spacing: 60){
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
                    .fontWeight(.bold)
            }
            .frame(width: UIScreen.main.bounds.width-20, alignment: .leading)
            VStack{
                HStack(spacing: 8){
                    Image("\(iconArr[icon])") //랜덤 출력
                        .resizable()
                        .frame(width: 64, height: 64)
                    VStack{
                        if isEditingUserName { //username 편집(textfield)
                            HStack{
                                VStack{
                                    TextField("username을 입력해주세요", text: $username)
                                        .disableAutocorrection(true) //자동 수정 비활성화
                                    Divider()
                                        .padding(.top, -6)
                                }
                                .frame(width: UIScreen.main.bounds.width/2, height: 28, alignment: .leading)
                                Button(action: {
                                    self.isEditingUserName.toggle()
                                }){
                                    Image(systemName: "checkmark") //임시 icon
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width-120)
                        }
                        else{ //username 나타내는(text)
                            HStack(spacing: 8){
                                Text("\(userData.name) 님") //user data 가져오기
                                    .font(.system(size: 24, weight: .bold))
                                Button(action: {
                                    self.isEditingUserName.toggle()
                                }){
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width - 120, height: 28, alignment: .leading)
                        }
                        Text("\(userData.username)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.681))
                            .frame(width: UIScreen.main.bounds.width - 120, alignment: .leading)
                    }
                    .frame(width: UIScreen.main.bounds.width - 120, height: 60, alignment: .topLeading)
                }
                .frame(width: UIScreen.main.bounds.width - 40)
                Divider()
                    .padding(.top, 16)
                Spacer()
                Button(action:{
                    //logout 서버에 보내기
//                    vm.logOut()
                    //NavigationLink로 LoginView로 이동
                    popRootView = false
                    autoLogin = false
                    vm.loginState = false
                    //데이터 지우기 -> user id 데이터 지우기
                    print("log out")
                }){
                    Text("로그아웃")
                        .underline()
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.gray)
                }
                .padding()
//                NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true).navigationBarHidden(true)){
//                    Text("로그아웃")
//                        .underline()
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundColor(Color.gray)
//                }
//                .simultaneousGesture(TapGesture().onEnded {
////                    vm.logOut() //logout 서버에 보내기
//                    print("logout")
//                })
            }//VStack2
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }//VStack1
        .frame(height: UIScreen.main.bounds.height-100, alignment: .top)
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(userData: .constant(UserResponse.Result(name: "", username: "")), popRootView: .constant(true), autoLogin: .constant(true))
            .environmentObject(ScrapViewModel())
    }
}
