//
//  ContentView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI

struct LoginView: View {
    @State private var id: String = ""
    @State private var pw: String = ""
//    @State private var showPW = false
    @State private var keepLogin = false
    @State private var showingSignUpSheet = false //회원가입 sheet state property
    @State private var rootView = false
    
    var body: some View {
        NavigationView{
            VStack{
//            Text("Scrap")
                Text("스크랩")
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
                VStack(spacing: 32){
                    TextField("아이디", text: $id)
                        .disableAutocorrection(true) //자동 수정 비활성화
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray)
                                .frame(height: 40, alignment: .center)
                        )
                    HStack{
    //                    if showPW {
    //                        TextField("비밀번호", text: $pw)
    //                            .disableAutocorrection(true) //자동 수정 비활성화
    //                            .padding(.horizontal)
    //                            .overlay(
    //                                RoundedRectangle(cornerRadius: 10)
    //                                    .stroke(Color.gray)
    //                                    .frame(height: 40, alignment: .center)
    //                            )
    //                    }
    //                    else {
                            SecureField("비밀번호", text: $pw)
                                .disableAutocorrection(true) //자동 수정 비활성화
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray)
                                        .frame(height: 40, alignment: .center)
                                )
    //                    }
    //                    Button(aciton: {
    //                        self.showPW.toggle()
    //                    }) {
    //                        Image(systemName: "eye")
    //                            .foregroundColor(.gray)
    //                    }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 10, trailing: 12))
                
//                Text("아이디/비밀번호가 맞지 않습니다.") //관련 에러 메세지 따로 출력되도록
//                    .font(.caption)
//                    .foregroundColor(Color.red)
//                    .lineLimit(0)
//                    .frame(width: UIScreen.main.bounds.width - 32, alignment: .topLeading)
////                    .visibility(.gone)
//
                HStack(){ //로그인 유지 체크 박스
                    Spacer()
                    HStack{
                        Button(action: {
                            //stayLogin
                            
                            self.keepLogin.toggle()
                        }) {
                            if keepLogin {
                                Image(systemName: "checkmark.square")
                                    .foregroundColor(Color.gray)
                            }else{
                                Image(systemName: "square")
                                    .foregroundColor(Color.gray)
                                //activeLogin==true, "checkmark.square"
                                //activeLogin==false, "square"
                            }
                        }
                        Text("로그인 유지")
                    }
                    .padding(.horizontal, 14)
                }
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 12, trailing: 0))
                
                VStack(spacing: 12){
                    Button(action: { //login button
                    
                    }) {
                        Text("로그인")
                            .frame(width: UIScreen.main.bounds.width - 48, height: 32, alignment: .center)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    Button(action: { //login button
                        //카카오로 연결
                    }) {
                        Text("카카오 로그인")
                            .frame(width: UIScreen.main.bounds.width - 48, height: 32, alignment: .center)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(Color.yellow)
                            .cornerRadius(12)
                    }
                }
                NavigationLink(destination: SignUpView(rootView: $rootView), isActive: $rootView){
                    Text("회원가입")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.gray)
                        .underline()
                }
//                Button(action: {
//                    self.showingSignUpSheet.toggle()
//                }){
//                    Text("회원가입")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(Color.gray)
//                        .underline()
//                }
//                .fullScreenCover(isPresented: $showingSignUpSheet) {
//                    //sheet에 표시될 뷰를 할당
//                    SignUpView()
//                }
                .padding(.top, 12)
            }
            .padding(.bottom, 32)
        }
    }
    
    func postInfor(id: String){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "https://hana-umc.shop/user/duplicate?id=test0303")!
        var request = URLRequest(url: url)
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            LoginView()
            SignUpView(rootView: .constant(true))
            HomeView(rootView: .constant(true))
            MyPageView(rootView: .constant(true))
            SideMenuView(isAddingCategory: .constant(false))
            SaveDataView()
        }
    }
}

//=========================visibility modifier=======================
//visible, invisible, gone 세 가지 종류
//invisible: 보이진 않지만 사라지진 않음
//gone: UI 개체가 아예 사라진 경우

enum ViewVisibility: CaseIterable {
  case visible, // view is fully visible
       invisible, // view is hidden but takes up space
       gone // view is fully removed from the view hierarchy
}

extension View {
  @ViewBuilder func visibility(_ visibility: ViewVisibility) -> some View {
    if visibility != .gone {
      if visibility == .visible {
        self
      } else {
        hidden()
      }
    }
  }
}
