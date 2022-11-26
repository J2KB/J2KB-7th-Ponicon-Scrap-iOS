//
//  SignUpView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import Combine
import UIKit

struct SignUpView: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //pop
    @EnvironmentObject var vm : UserViewModel
    @Binding var movingToSignUp : Bool
    @State private var checkInfo = [9,9,9,9]
    @State private var username = ""
    @State private var email = ""
    @State private var pw = ""
    @State private var checkPW = ""
    let maxUserName = 30
    let maxIdPw = 16
    let toastMessages = [0: "한글 또는 영어로만 이뤄질 수 있습니다",
                         1: "이름을 입력하세요",
                         2: "5~15자의 영문 소문자, 숫자를 포함해야 합니다",
                         3: "이메일을 입력하세요",
                         4: "이미 가입된 이메일입니다",
                         5: "비밀번호를 입력하세요",
                         6: "5~15자의 영어, 숫자를 포함해야 합니다",
                         7: "비밀번호와 일치하지 않습니다",
                         8: "비밀번호 확인을 입력하세요",
                         9: "",
                         10: "이메일 형식으로 입력해주세요",
                         11: "사용 가능한 이메일입니다"] //Dictionary 형태로 메세지 모음
    
    var backButton : some View { //custom back button
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.backward") // BackButton Image
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                Text("회원가입") //translated Back button title
                    .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                    .fontWeight(.semibold)
            }
        }
    }
    
    //email 형식이 맞는지 체크
    func isValidEmail(email:String){
        guard email != "" else { //0자인 경우
            self.checkInfo[1] = 3
            return
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if email.range(of: emailRegEx, options: .regularExpression) == nil {
            self.checkInfo[1] = 10
        }else {
            self.checkInfo[1] = 9
        }
    }
    
    //이름 조건 체크
    func isValidName(name: String) {
        guard name != "" else { //0자인 경우
            self.checkInfo[0] = 1
            return
        }
        let nameRegEx = "[가-힣A-Za-z]{1,30}"
        if name.range(of: nameRegEx, options: .regularExpression) == nil {
            self.checkInfo[0] = 0
        }else { //이름 형식 맞지 않음
            self.checkInfo[0] = 9
        }
    }
    
    //비번 조건 체크 🚨
    func isValidPW(pw: String){
        guard pw != "" else { //0자인 경우
            self.checkInfo[2] = 5
            return
        }
        let passwordRegEx = "[A-Z0-9a-z~!@#$%^&*]{5-16}"
        if pw.range(of: passwordRegEx, options: .regularExpression) == nil {
            self.checkInfo[2] = 6
        }else { //pw 형식 맞지 않음
            self.checkInfo[2] = 9
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            ZStack{
                VStack(spacing: 48){
                    Spacer()
                    VStack(spacing: 20){ //이름 입력창
                        HStack{
                            Text("이름")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("basic_text"))
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        VStack{
                            TextField("이름을 입력하세요", text: $username)
                                .onSubmit {
                                    isValidName(name: username)
                                }
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, height: 28, alignment: .leading)
                                .onReceive(Just(username), perform: { _ in  //최대 30글자(이상은 입력안되도록)
                                    if maxUserName < username.count {
                                        username = String(username.prefix(maxUserName))
                                    }
                                })
                            Divider()
                                .foregroundColor(.gray_bold)
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5)
                            Text(toastMessages[checkInfo[0]]!) //관련 에러 메세지 따로 출력되도록
                                .font(.caption)
                                .foregroundColor(.red_error)
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        }
                    }
                    VStack{ //이메일 입력창
                        HStack{
                            Text("이메일")
                                .foregroundColor(Color("basic_text"))
                                .font(.system(size: 20, weight: .semibold))
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        VStack{
                            HStack{
                                TextField("이메일을 입력하세요", text: $email)
                                    .keyboardType(.asciiCapable)
                                    .onSubmit {
                                        isValidEmail(email: email)
                                    }
                                    .onReceive(Just(email), perform: { _ in  //최대 15글자
                                        if maxIdPw < email.count {
                                            email = String(email.prefix(maxIdPw))
                                        }
                                    })
                                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5 - 68, height: 28, alignment: .leading)
                                Button(action: {
                                    //아이디 중복 확인 버튼
                                    vm.checkDuplication(email: email) //📡 이메일 중복 확인 api 통신 -> 동기적으로 진행해야 됨
                                    print(vm.duplicateMessage)
                                    self.checkInfo[1] = vm.duplicateMessage //4: duplicate, 9: duplicate
                                    print(vm.duplicateMessage)
                                }){
                                    Text("중복 확인")
                                        .padding(2)
                                        .font(.system(size: 12, weight: .semibold))
                                        .frame(width: 60, height: 32, alignment: .center)
                                        .foregroundColor(Color.white)
                                        .background(Color("main_accent"))
                                        .cornerRadius(8)
                                }
                            }
                            Divider()
                                .foregroundColor(.gray_bold)
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        }
                        Text(toastMessages[checkInfo[1]]!) //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(.red_error)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                    }
                    VStack{ //비밀번호 입력창
                        HStack{
                            Text("비밀번호")
                                .foregroundColor(Color("basic_text"))
                                .font(.system(size: 20, weight: .semibold))
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        TextField("비밀번호를 입력하세요", text: $pw)
                            .keyboardType(.asciiCapable)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, height: 28, alignment: .leading)
                            .onSubmit {
                                //fail -> 영어만 있거나 숫자만 있는 경우 || 5보다 작은 문자열 길이
//                                isValidPW(pw: pw)
                                let countLetter = pw.filter({$0.isLetter}).count //영어 개수
                                print(countLetter)
                                let countNumber = pw.filter({$0.isNumber}).count //숫자 개수
                                print(countNumber)
                                if countNumber == 0 || countLetter == 0 || 1...4 ~= pw.count {
                                    self.checkInfo[2] = 6
                                }
                                //0자 입력시
                                else if pw.isEmpty { self.checkInfo[2] = 5 }
                                else { self.checkInfo[2] = 9 }
                            }
                            .onReceive(Just(pw), perform: { _ in  //최대 15글자
                                if maxIdPw < pw.count {
                                    pw = String(pw.prefix(maxIdPw))
                                }
                            })
                        Divider()
                            .foregroundColor(.gray_bold)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        Text(toastMessages[checkInfo[2]]!) //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(.red_error)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                    }
                    VStack{ //비밀번호 확인 입력창
                        HStack{
                            Text("비밀번호 확인")
                                .foregroundColor(Color("basic_text"))
                                .font(.system(size: 20, weight: .semibold))
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        TextField("비밀번호 확인을 입력하세요", text: $checkPW)
                            .keyboardType(.asciiCapable)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, height: 28, alignment: .leading)
                            .onSubmit {
                                if pw != checkPW { self.checkInfo[3] = 7 }
                                else if checkPW.isEmpty { self.checkInfo[3] = 8 }
                                else { self.checkInfo[3] = 9 }
                            }
                        Divider()
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        Text(toastMessages[checkInfo[3]]!) //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(.red_error)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                    }
                    Spacer()
                }
                .ignoresSafeArea(.keyboard)
                VStack{
                    Spacer()
                    Button(action:{
                        if username.isEmpty { self.checkInfo[0] = 1 }
                        if email.isEmpty { self.checkInfo[1] = 3 }
                        if pw.isEmpty { self.checkInfo[2] = 5 }
                        if checkPW.isEmpty { self.checkInfo[3] = 8 }
                        if isValidSignUp() { //회원가입 모든 조건 통과
                            movingToSignUp = false //LoginView로 이동 -> 위 코드랑 같이 조건 체크 통과시에만
                            vm.postSignUp(email: email, password: pw, name: username) //📡 SignUp API (모든 조건 통과)
                        }
                    }){
                        Text("회원가입")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width / 2.2, height: 44, alignment: .center)
                            .foregroundColor(.white)
                            .background(Color("main_accent"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, -40)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .center)
        .navigationBarTitle("",displayMode: .inline)
        .background(Color("background"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    func isValidSignUp() -> Bool { //전체 조회
        return !username.isEmpty && !email.isEmpty && !pw.isEmpty && !checkPW.isEmpty && checkInfo[0] == 9 && checkInfo[1] == 9 && checkInfo[2] == 9 && checkInfo[3] == 9
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(movingToSignUp: .constant(true))
            .environmentObject(ScrapViewModel())
            .preferredColorScheme(.dark)
    }
}

