//
//  SignUpView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import Combine

let error_red = Color(red: 255/255, green: 84/255, blue: 84/255)
let light_gray = Color(red: 217/255, green: 217/255, blue: 217/255)
let bold_blue = Color(red: 20/255, green: 142/255, blue: 174/255)
let light_blue = Color(red: 70/255, green: 193/255, blue: 241/255)

struct SignUpView: View {
    @EnvironmentObject var vm : UserViewModel
    @State private var username = ""
    @State private var id = ""
    @State private var pw = ""
    @State private var checkPW = ""
    @State private var signUpButton = false
    let maxUserName = 30
    @Binding var rootView : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //pop

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
                    .fontWeight(.semibold)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 32){
            VStack{
                VStack{
                    HStack{
                        Text("이름")
                            .font(.system(size: 20, weight: .semibold))
                        Text("*")
                            .foregroundColor(bold_blue)
                            .padding(.leading, -2)
                    }
                    .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                    TextField("이름을 입력하세요", text: $username)
                        .frame(width: UIScreen.main.bounds.width/1.2, height: 28, alignment: .leading)
                        .onReceive(Just(username), perform: { _ in  //최대 30글자
                            if maxUserName < username.count {
                                username = String(username.prefix(maxUserName))
                            }
                        })
                    Divider()
                        .foregroundColor(light_gray)
                        .frame(width: UIScreen.main.bounds.width/1.2)
                    if username.isEmpty, signUpButton {
                        Text("*이름을 입력하세요.") //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(error_red)
                            .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                    }
                }
                .padding(.bottom, 16)
                VStack{
                    HStack{
                        Text("아이디")
                            .font(.system(size: 20, weight: .semibold))
                        Text("*")
                            .foregroundColor(bold_blue)
                            .padding(.leading, -2)
                    }
                    .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                    VStack{
                        HStack{
                            TextField("아이디를 입력하세요", text: $id)
                                .frame(width: UIScreen.main.bounds.width/1.65, height: 28, alignment: .leading)
                            Button(action: {
                                //아이디 중복 확인 버튼
                            }){
                                Text("중복 확인")
                                    .padding()
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(width: 80, height: 32, alignment: .center)
                                    .foregroundColor(Color.white)
                                    .background(light_blue)
                                    .cornerRadius(8)
                            }
                        }
                        Divider()
                            .foregroundColor(light_gray)
                            .frame(width: UIScreen.main.bounds.width/1.2)
                    }
                    if id.isEmpty, signUpButton {
                        Text("*아이디를 입력하세요.") //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(error_red)
                            .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                        }
                }
                .padding(.bottom, 16)
                VStack{
                    HStack{
                        Text("비밀번호")
                            .font(.system(size: 20, weight: .semibold))
                        Text("*")
                            .foregroundColor(bold_blue)
                            .padding(.leading, -2)
                    }
                    .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                    TextField("비밀번호를 입력하세요", text: $pw)
                        .frame(width: UIScreen.main.bounds.width/1.2, height: 28, alignment: .leading)
                    Divider()
                        .foregroundColor(light_gray)
                        .frame(width: UIScreen.main.bounds.width/1.2)
                    if pw.isEmpty, signUpButton {
                        Text("*비밀번호를 입력하세요.") //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(error_red)
                            .frame(width: UIScreen.main.bounds.width/1.2, alignment: .topLeading)
                    }
                }
                .padding(.bottom, 16)
                VStack{
                    HStack{
                        Text("비밀번호 확인")
                            .font(.system(size: 20, weight: .semibold))
                        Text("*")
                            .foregroundColor(bold_blue)
                            .padding(.leading, -2)
                    }
                    .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                    TextField("비밀번호 확인을 입력하세요", text: $checkPW)
                        .frame(width: UIScreen.main.bounds.width/1.2, height: 28, alignment: .leading)
                    Divider()
                        .frame(width: UIScreen.main.bounds.width/1.2)
                    if pw != checkPW {
                        Text("*비밀번호와 일치하지 않습니다.") //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(error_red)
                            .frame(width: UIScreen.main.bounds.width/1.2, alignment: .topLeading)
//                            .hidden()
                    }
                    if checkPW.isEmpty, signUpButton {
                        Text("*비밀번호 확인을 입력하세요.") //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(error_red)
                            .frame(width: UIScreen.main.bounds.width/1.2, alignment: .topLeading)
                    }
                }
                .padding(.bottom, 16)
            }
            
            //모두 올바른 입력값인 경우 회원가입 성공 -> HomeView 이동
            //실패하면 버튼 클릭 x -> 비활성화하면 어떨지
            //우선 상관없이 바로 HomeView 이동 가능하도록
            NavigationLink(destination: MainHomeView(rootView: $rootView).navigationBarBackButtonHidden(true).navigationBarHidden(true), isActive: $vm.signUpState){
                Text("회원가입")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: UIScreen.main.bounds.width / 2.2, height: 44, alignment: .center)
                    .foregroundColor(Color.white)
                    .background(light_blue)
                    .cornerRadius(10)
            }
            .simultaneousGesture(TapGesture().onEnded {
                self.signUpButton = true
                vm.postSignUp(userid: id, password: pw, name: username)
            })
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
        SignUpView(rootView: .constant(true))
            .environmentObject(ScrapViewModel())
    }
}
