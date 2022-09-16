//
//  SignUpView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import Combine

struct SignUpView: View {
    @State private var username = ""
    @State private var id = ""
    @State private var pw = ""
    @State private var checkPW = ""
    let maxUserName = Int(30)
    @Binding var rootView : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var backButton : some View { //custom back button
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.backward") // BackButton Image
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
                Text("회원가입") //translated Back button title
                    .foregroundColor(.black)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 32){
            VStack{
                Text("이름")
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .font(.system(size: 20, weight: .semibold))
                TextField("이름을 입력하세요", text: $username)
                    .padding(.horizontal, 20)
                    .onReceive(Just(username), perform: { _ in
                        if maxUserName < username.count {
                            username = String(username.prefix(maxUserName))
                        }
                    })
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40)
                Text("*이름을 입력하세요.") //관련 에러 메세지 따로 출력되도록
                    .font(.caption)
                    .foregroundColor(Color.red)
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .topLeading)
//                    .visibility(.gone)
            }
            VStack{
                Text("아이디")
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .font(.system(size: 20, weight: .semibold))
                TextField("아이디를 입력하세요", text: $id)
                    .padding(.horizontal, 20)
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40)
                Text("*아이디를 입력하세요.") //관련 에러 메세지 따로 출력되도록
                    .font(.caption)
                    .foregroundColor(Color.red)
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .topLeading)
//                    .visibility(.gone)
            }
            VStack{
                Text("비밀번호")
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .font(.system(size: 20, weight: .semibold))
                TextField("비밀번호를 입력하세요", text: $pw)
                    .padding(.horizontal, 20)
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40)
                Text("*비밀번호를 입력하세요.") //관련 에러 메세지 따로 출력되도록
                    .font(.caption)
                    .foregroundColor(Color.red)
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .topLeading)
//                    .visibility(.gone)
            }
            VStack{
                Text("비밀번호 확인")
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .font(.system(size: 20, weight: .semibold))
                TextField("비밀번호 확인을 입력하세요", text: $checkPW)
                    .padding(.horizontal, 20)
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40)
                Text("*비밀번호 확인을 입력하세요.") //관련 에러 메세지 따로 출력되도록
                    .font(.caption)
                    .foregroundColor(Color.red)
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .topLeading)
//                    .visibility(.gone)
            }
            //모두 올바른 입력값인 경우 회원가입 성공 -> HomeView 이동
            //실패하면 버튼 클릭 x -> 비활성화하면 어떨지
            //우선 상관없이 바로 HomeView 이동 가능하도록
            NavigationLink(destination: HomeView(rootView: $rootView).navigationBarBackButtonHidden(true).navigationBarHidden(true)){
                Text("회원가입")
                    .frame(width: UIScreen.main.bounds.width / 2, height: 40, alignment: .center)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 28)
        }
        .padding(.bottom, 80)
        .navigationBarTitle("",displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
//        SignUpView()
        LoginView()
    }
}

enum Visibility: CaseIterable {
  case visible, // view is fully visible
       invisible, // view is hidden but takes up space
       gone // view is fully removed from the view hierarchy
}

extension View {
  @ViewBuilder func visibility(_ visibility: Visibility) -> some View {
    if visibility != .gone {
      if visibility == .visible {
        self
      } else {
        hidden()
      }
    }
  }
}
