//
//  SignUpView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import Combine
import UIKit

enum Field {
    case none, name, email, password, checkPassword
}

struct SignUpView: View {
    //MARK: - pop to Login View
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var checkSignUpInfomation = [1,3,5,8]
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var checkPassword = ""
    @State private var isEmailDuplicationChecking : Bool = false
    
    @FocusState private var focusField: Field?
    @Binding var goToSignUpView : Bool

    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    private let maxUserName = 30
    private let maxPassword = 16
    private var checkDuplicatedEmail : Int { return userVM.duplicateMessage }
    
    private let toastMessages : [Int : String] = [0: "한글 또는 영어로만 이뤄질 수 있습니다",
                                          1: "이름을 입력하세요",
                                          2: "이메일 형식으로 입력해주세요",
                                          3: "이메일을 입력하세요",
                                          4: "이미 가입된 이메일입니다",
                                          5: "비밀번호를 입력하세요",
                                          6: "5~16자의 영문/숫자를 포함해야 합니다",
                                          7: "비밀번호와 일치하지 않습니다",
                                          8: "비밀번호를 확인해주세요",
                                          9: "",
                                          10: "사용 가능한 이메일입니다",
                                          11: "비밀번호가 일치합니다",
                                          12: "이메일 중복을 확인해주세요"]
    
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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            ZStack{
                VStack(spacing: 40){
                    Spacer()
                    NameView
                    EmailView
                    PasswordView
                    PasswordCheckView
                    Spacer()
                }
                .ignoresSafeArea(.keyboard)
                VStack{
                    Spacer()
                    Button(action:{
                        print("회원가입?")
                        appearMessageTotal(name: username, email: email, password: password, checkPassword: checkPassword)
                        if isValidSignUp() { //가입 조건에 다 맞췄다면
                            print("회원가입!!")
                            goToSignUpView = false //로그인 화면으로 돌아가기
                            userVM.postSignUp(email: email, password: password, name: username) //📡 SignUp API (모든 조건 통과)
                        }
                    }){
                        Text("회원가입")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width / 1.1, height: 50, alignment: .center)
                            .foregroundColor(.white)
                            .background(Color("main_accent"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, -50)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .onTapGesture {
            self.hideKeyboard()
            appearMessageEachTextFieldWhenTappedScreen()
        }
        .onAppear {
            focusField = .name
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
    
    var NameView: some View {
        VStack(spacing: 10){
            HStack{
                Text("이름")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("basic_text"))
                Text("*")
                    .foregroundColor(.blue_bold)
                    .padding(.leading, -2)
            }
            .frame(width: screenWidth / 1.1, alignment: .leading)
            VStack{
                TextField("이름을 입력하세요", text: $username)
                    .focused($focusField, equals: .name)
                    .onSubmit {
                        isValidName(name: username)
                        self.changeFocusField()
                    }
                    .frame(width: screenWidth / 1.11, height: 20, alignment: .leading)
                    .onReceive(Just(username), perform: { _ in  //최대 30글자(이상은 입력안되도록)
                        if maxUserName < username.count {
                            username = String(username.prefix(maxUserName))
                        }
                    })
                Divider()
                    .foregroundColor(.gray_bold)
                    .frame(width: screenWidth / 1.1)
                Text(toastMessages[checkSignUpInfomation[0]]!) //관련 에러 메세지 따로 출력되도록
                    .font(.caption)
                    .foregroundColor(.red_error)
                    .frame(width: screenWidth / 1.125, alignment: .leading)
            }
        }
    }
    
    var EmailView: some View {
        VStack(spacing: 10){
            HStack{
                Text("이메일")
                    .foregroundColor(Color("basic_text"))
                    .font(.system(size: 18, weight: .semibold))
                Text("*")
                    .foregroundColor(.blue_bold)
                    .padding(.leading, -2)
            }
            .frame(width: screenWidth / 1.1, alignment: .leading)
            VStack{
                HStack{
                    VStack{
                        TextField("이메일을 입력하세요", text: $email)
                            .focused($focusField, equals: .email)
                            .keyboardType(.asciiCapable)
                            .onSubmit {
                                isValidEmail(email: email)
                                isEmailDuplicationChecking = false
                                self.changeFocusField()
                            }
                            .frame(width: screenWidth / 1.37, height: 20, alignment: .leading)
                        Divider()
                            .foregroundColor(.gray_bold)
                            .frame(width: screenWidth / 1.37, alignment: .leading)
                    }
                    //MARK: - 이메일 중복 확인 버튼
                    Button(action: {
                        userVM.checkDuplication(email: email) //📡 이메일 중복 확인 api 통신
                        isEmailDuplicationChecking = true
                    }){
                        Text("중복 확인")
                            .padding(2)
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: screenWidth / 6.7, height: 26, alignment: .center)
                            .foregroundColor(Color.white)
                            .background(Color("main_accent"))
                            .cornerRadius(8)
                    }
                }
                
            }
            Text(isEmailDuplicationChecking ? toastMessages[checkDuplicatedEmail]! : toastMessages[checkSignUpInfomation[1]]!) //관련 에러 메세지 따로 출력되도록
                .font(.caption)
                .foregroundColor(isEmailDuplicationChecking && checkDuplicatedEmail == 10 ? .main_accent : .red_error)
                .frame(width: screenWidth / 1.12, alignment: .leading)
        }
    }
    
    var PasswordView: some View {
        VStack(spacing: 10){
            HStack{
                Text("비밀번호")
                    .foregroundColor(Color("basic_text"))
                    .font(.system(size: 18, weight: .semibold))
                Text("*")
                    .foregroundColor(.blue_bold)
                    .padding(.leading, -2)
            }
            .frame(width: screenWidth / 1.1, alignment: .leading)
            TextField("비밀번호를 입력하세요 (최소 5자)", text: $password)
                .focused($focusField, equals: .password)
                .keyboardType(.asciiCapable)
                .frame(width: UIScreen.main.bounds.width / 1.11, height: 20, alignment: .leading)
                .onSubmit {
                    isValidPassword(password: password)
                    self.changeFocusField()
                }
                .onReceive(Just(password), perform: { _ in  //최대 15글자
                    if maxPassword < password.count {
                        password = String(password.prefix(maxPassword))
                    }
                })
            Divider()
                .foregroundColor(.gray_bold)
                .frame(width: screenWidth / 1.1, alignment: .leading)
            Text(toastMessages[checkSignUpInfomation[2]]!) //관련 에러 메세지 따로 출력되도록
                .font(.caption)
                .foregroundColor(.red_error)
                .frame(width: screenWidth / 1.125, alignment: .leading)
        }
    }
    
    var PasswordCheckView: some View {
        VStack(spacing: 10){
            HStack{
                Text("비밀번호 확인")
                    .foregroundColor(Color("basic_text"))
                    .font(.system(size: 18, weight: .semibold))
                Text("*")
                    .foregroundColor(.blue_bold)
                    .padding(.leading, -2)
            }
            .frame(width: screenWidth / 1.1, alignment: .leading)
            TextField("비밀번호 확인을 입력하세요", text: $checkPassword)
                .focused($focusField, equals: .checkPassword)
                .keyboardType(.asciiCapable)
                .frame(width: screenWidth / 1.11, height: 20, alignment: .leading)
                .onSubmit {
                    isEqualWithPassword(password: password, checkPassword: checkPassword)
                    self.changeFocusField()
                }
            Divider()
                .frame(width: screenWidth / 1.1, alignment: .leading)
            Text(toastMessages[checkSignUpInfomation[3]]!) //관련 에러 메세지 따로 출력되도록
                .font(.caption)
                .foregroundColor(checkSignUpInfomation[3] == 11 ? .main_accent : .red_error)
                .frame(width: screenWidth / 1.125, alignment: .leading)
        }
    }
    
    //MARK: - 이메일 입력 값 확인
    private func isValidEmail(email:String){
        guard email != "" else { self.checkSignUpInfomation[1] = 3; return }
        let emailRegEx = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        if email.range(of: emailRegEx, options: .regularExpression) == nil {
            self.checkSignUpInfomation[1] = 2
        }else {
            self.checkSignUpInfomation[1] = 9
        }
    }
    
    //MARK: - 이름 입력 값 확인
    private func isValidName(name: String) {
        guard name != "" else { self.checkSignUpInfomation[0] = 1; return }
        let nameRegEx = "^[가-힣A-Za-z]{1,30}$"
        if name.range(of: nameRegEx, options: .regularExpression) == nil {
            self.checkSignUpInfomation[0] = 0
        }else {
            self.checkSignUpInfomation[0] = 9
        }
    }
    
    //MARK: - 비밀번호 입력 값 확인
    private func isValidPassword(password: String){
        guard !password.isEmpty else { self.checkSignUpInfomation[2] = 5; return }
        let countLetter = password.filter({$0.isLetter}).count //영어 개수
        let countNumber = password.filter({$0.isNumber}).count //숫자 개수
        if countNumber == 0 || countLetter == 0 || 1...4 ~= password.count { self.checkSignUpInfomation[2] = 6 }
        else { self.checkSignUpInfomation[2] = 9 }
    }
    
    //MARK: - 비밀번호 일치 확인
    private func isEqualWithPassword(password: String, checkPassword: String) {
        guard !checkPassword.isEmpty else { self.checkSignUpInfomation[3] = 8; return } //empty
        self.checkSignUpInfomation[3] = password != checkPassword ? 7 : 11 //equal or not
    }
    
    //MARK: - 모든 값이 타당한지 한번 더 체크
    private func isValidSignUp() -> Bool {
        return !username.isEmpty && !email.isEmpty && !password.isEmpty && !checkPassword.isEmpty && checkSignUpInfomation[0] == 9 && checkSignUpInfomation[1] == 9 && checkSignUpInfomation[2] == 9 && checkSignUpInfomation[3] == 11 && isEmailDuplicationChecking
    }
    
    //MARK: - 화면 터치 시 validity 확인 후 그에 맞는 message 출력
    private func appearMessageEachTextFieldWhenTappedScreen() {
        switch focusField {
        case .name:
            //입력에 맞는 메세지 출력해야됨
            isValidName(name: username)
        case .email:
            isValidEmail(email: email)
            isEmailDuplicationChecking = false
        case .password:
            isValidPassword(password: password)
        case .checkPassword:
            isEqualWithPassword(password: password, checkPassword: checkPassword)
        default:
            break
        }
    }
    
    //MARK: - 전체 validity 확인 후 message 출력
    private func appearMessageTotal(name: String, email: String, password: String, checkPassword: String) {
        //입력을 안한 상태(isEmpty) -> 입력하라고 값 넣기
        if name.isEmpty { checkSignUpInfomation[0] = 1 }
        if email.isEmpty { checkSignUpInfomation[1] = 3 }
        if password.isEmpty { checkSignUpInfomation[2] = 5 }
        if checkPassword.isEmpty { checkSignUpInfomation[3] = 8 }
        //중복확인 안한 상태(checkEmailDuplication=false) -> 중복 확인하라고 하기 12번
        if !isEmailDuplicationChecking { checkSignUpInfomation[1] = 12 }
    }
    
    //MARK: - FocusField 변경
    private func changeFocusField() {
        switch focusField {
        case .name:
            focusField = .email
        case .email:
            focusField = .password
        case .password:
            focusField = .checkPassword
        case .checkPassword:
            focusField = Field.none
        default:
            break
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone 14 Pro", "iPhone 8", "iPhone 13 mini"], id: \.self) {
            SignUpView(goToSignUpView: .constant(true))
                .environmentObject(ScrapViewModel())
                .previewDevice(PreviewDevice(rawValue: $0))
                .previewDisplayName($0) //각 프리뷰 컨테이너 이름지정
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
