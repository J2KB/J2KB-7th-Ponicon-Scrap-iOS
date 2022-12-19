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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //MARK: - pop to Login View
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var checkSignUpInfomation = [9,9,9,9]
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var checkPassword = ""
    @State private var isEmailDuplicationChecking : Bool = false
    @Binding var goToSignUpView : Bool

    let maxUserName = 30
    let maxPassword = 16
    var checkDuplicatedEmail : Int { return userVM.duplicateMessage }
    
    let toastMessages : [Int : String] = [0: "한글 또는 영어로만 이뤄질 수 있습니다",
                                          1: "이름을 입력하세요",
                                          2: "이메일 형식으로 입력해주세요",
                                          3: "이메일을 입력하세요",
                                          4: "이미 가입된 이메일입니다",
                                          5: "비밀번호를 입력하세요",
                                          6: "5~16자의 영어, 숫자를 포함해야 합니다",
                                          7: "비밀번호와 일치하지 않습니다",
                                          8: "비밀번호 확인을 입력하세요",
                                          9: "",
                                          10: "사용 가능한 이메일입니다"]
    
    var backButton : some View { //custom back button
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.backward")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("basic_text"))
                Text("회원가입")
                    .foregroundColor(Color("basic_text"))
                    .fontWeight(.semibold)
            }
        }
    }
    
    //MARK: - 이메일 입력 값 확인
    private func isValidEmail(email:String){
        guard email != "" else {
            self.checkSignUpInfomation[1] = 3
            return
        }
        let emailRegEx = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        if email.range(of: emailRegEx, options: .regularExpression) == nil {
            self.checkSignUpInfomation[1] = 2
        }else {
            self.checkSignUpInfomation[1] = 9
        }
    }
    
    //MARK: - 이름 입력 값 확인
    private func isValidName(name: String) {
        guard name != "" else {
            self.checkSignUpInfomation[0] = 1
            return
        }
        let nameRegEx = "^[가-힣A-Za-z]{1,30}$"
        let engRegEx = "^[A-Za-z]*$"  //isOnlyEnglish?
        let korRegEx = "^[가-힣]*$"    //isOnlyKorean?
        if name.range(of: nameRegEx, options: .regularExpression) == nil ||
            name.range(of: engRegEx, options: .regularExpression) == nil &&
            name.range(of: korRegEx, options: .regularExpression) == nil {
            self.checkSignUpInfomation[0] = 0
        }else {
            self.checkSignUpInfomation[0] = 9
        }
    }
    
    //MARK: - 비밀번호 입력 값 확인
    private func isValidPW(pw: String){
        guard pw != "" else { //0자인 경우
            self.checkSignUpInfomation[2] = 5
            return
        }
        let passwordRegEx = "[A-Z0-9a-z~!@#$%^&*]{5-16}"
        if pw.range(of: passwordRegEx, options: .regularExpression) == nil {
            self.checkSignUpInfomation[2] = 6
        }else { //pw 형식 맞지 않음
            self.checkSignUpInfomation[2] = 9
        }
    }
    
    //MARK: - 모든 값이 타당한지 한번 더 체크
    private func isValidSignUp() -> Bool {
        return !username.isEmpty && !email.isEmpty && !password.isEmpty && !checkPassword.isEmpty && checkSignUpInfomation[0] == 9 && checkSignUpInfomation[1] == 9 && checkSignUpInfomation[2] == 9 && checkSignUpInfomation[3] == 9
    }
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            ZStack{
                VStack(spacing: 48){
                    Spacer()
                    VStack(spacing: 20){
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
                            Text(toastMessages[checkSignUpInfomation[0]]!) //관련 에러 메세지 따로 출력되도록
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
                                        isEmailDuplicationChecking = false
                                    }
                                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5 - 68, height: 28, alignment: .leading)
                                //MARK: - 이메일 중복 확인 버튼
                                Button(action: {
                                    userVM.checkDuplication(email: email) //📡 이메일 중복 확인 api 통신
                                    isEmailDuplicationChecking = true
                                    print(userVM.duplicateMessage)
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
                        Text(isEmailDuplicationChecking ? toastMessages[checkDuplicatedEmail]! : toastMessages[checkSignUpInfomation[1]]!) //관련 에러 메세지 따로 출력되도록
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
                        TextField("비밀번호를 입력하세요", text: $password)
                            .keyboardType(.asciiCapable)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, height: 28, alignment: .leading)
                            .onSubmit {
                                //fail -> 영어만 있거나 숫자만 있는 경우 || 5보다 작은 문자열 길이
                                let countLetter = password.filter({$0.isLetter}).count //영어 개수
                                let countNumber = password.filter({$0.isNumber}).count //숫자 개수
                                if countNumber == 0 || countLetter == 0 || 1...4 ~= password.count {
                                    self.checkSignUpInfomation[2] = 6
                                }
                                //0자 입력시
                                else if password.isEmpty { self.checkSignUpInfomation[2] = 5 }
                                else { self.checkSignUpInfomation[2] = 9 }
                            }
                            .onReceive(Just(password), perform: { _ in  //최대 15글자
                                if maxPassword < password.count {
                                    password = String(password.prefix(maxPassword))
                                }
                            })
                        Divider()
                            .foregroundColor(.gray_bold)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        Text(toastMessages[checkSignUpInfomation[2]]!) //관련 에러 메세지 따로 출력되도록
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
                        TextField("비밀번호 확인을 입력하세요", text: $checkPassword)
                            .keyboardType(.asciiCapable)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, height: 28, alignment: .leading)
                            .onSubmit {
                                if password != checkPassword { self.checkSignUpInfomation[3] = 7 }
                                else if checkPassword.isEmpty { self.checkSignUpInfomation[3] = 8 }
                                else { self.checkSignUpInfomation[3] = 9 }
                            }
                        Divider()
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 1.5, alignment: .leading)
                        Text(toastMessages[checkSignUpInfomation[3]]!) //관련 에러 메세지 따로 출력되도록
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
                        if username.isEmpty { self.checkSignUpInfomation[0] = 1 }
                        if email.isEmpty { self.checkSignUpInfomation[1] = 3 }
                        if password.isEmpty { self.checkSignUpInfomation[2] = 5 }
                        if checkPassword.isEmpty { self.checkSignUpInfomation[3] = 8 }
                        if isValidSignUp() {
                            goToSignUpView = false
                            userVM.postSignUp(email: email, password: password, name: username) //📡 SignUp API (모든 조건 통과)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .gesture(DragGesture().onEnded({
             if $0.translation.width > 100 {
                 withAnimation(.easeInOut) {
                     self.presentationMode.wrappedValue.dismiss()
                 }
             }
         }))
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(goToSignUpView: .constant(true))
            .environmentObject(ScrapViewModel())
            .preferredColorScheme(.dark)
    }
}

