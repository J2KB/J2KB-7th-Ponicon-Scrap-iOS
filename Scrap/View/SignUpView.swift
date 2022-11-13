//
//  SignUpView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import Combine

struct SignUpView: View {
    @EnvironmentObject var vm : UserViewModel
    @State private var username = ""
    @State private var id = ""
    @State private var pw = ""
    @State private var checkPW = ""
    let maxUserName = 30
    let maxIdPw = 16
    @Binding var movingToSignUp : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //pop
    
    let toastMessages = [0 : "한글 또는 영어로만 이뤄질 수 있습니다", 1: "이름을 입력하세요", 2: "5~15자의 영문 소문자, 숫자를 포함해야 합니다",
                         3: "이메일을 입력하세요", 4: "이미 가입된 이메일입니다", 5: "비밀번호를 입력하세요", 6: "5~15자의 영어, 숫자를 포함해야 합니다",
                         7: "비밀번호와 일치하지 않습니다", 8: "비밀번호 확인을 입력하세요", 9: "", 10: "이메일 형식으로 입력해주세요"] //Dictionary 형태로 메세지 모음
    @State private var checkInfo = [9,9,9,9]
    
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
    
//    func isValidName(name: String?) -> Bool { //name 값이 맞는지 틀린지 true, false로 반환하는 함수
//        guard name != nil else {return false}
//        let nameRegEx = "[가-힣A-Za-z]{1-30}"
//        let pred = NSPredicate(format: "SEFL MATCHES %@", nameRegEx)
//        return pred.evaluate(with: name)
//    }
    
    func isValidEmail(email:String) -> Bool {
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
       return emailTest.evaluate(with: email)
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
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        VStack{
                            TextField("이름을 입력하세요", text: $username)
                                .frame(width: UIScreen.main.bounds.width/1.2, height: 28, alignment: .leading)
                                .onSubmit {
                                    //특수문자 혹은 숫자가 들어간 경우 -> 에러 메세지
                                    if username.filter({$0.isLetter}).count != username.count {
                                        self.checkInfo[0] = 0
                                    }
                                    //0자 입력시
                                    else if username.isEmpty {
                                        self.checkInfo[0] = 1
                                    }
                                    else {
                                        self.checkInfo[0] = 9
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                                .onReceive(Just(username), perform: { _ in  //최대 30글자
                                    if maxUserName < username.count {
                                        username = String(username.prefix(maxUserName))
                                    }
                                })
                            Divider()
                                .foregroundColor(.gray_bold)
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2)
                            Text(toastMessages[checkInfo[0]]!) //관련 에러 메세지 따로 출력되도록
                                .font(.caption)
                                .foregroundColor(.red_error)
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        }
                    }
                    VStack{ //이메일 입력창
                        HStack{
                            Text("이메일")
                                .font(.system(size: 20, weight: .semibold))
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        VStack{
                            HStack{
                                TextField("이메일을 입력하세요", text: $id)
                                    .keyboardType(.asciiCapable)
                                    .frame(width: UIScreen.main.bounds.width/1.65, height: 28, alignment: .leading)
                                    .onSubmit {
                                        //이메일 형식이 아닌 경우
                                        if isValidEmail(email: id) == false {
                                            self.checkInfo[1] = 10
                                        }
                                        //0자 입력시
                                        else if id.isEmpty {
                                            self.checkInfo[1] = 3
                                        }
                                        else {
                                            self.checkInfo[1] = 9
                                        }
                                    }
                                    .onReceive(Just(id), perform: { _ in  //최대 15글자
                                        if maxIdPw < id.count {
                                            id = String(id.prefix(maxIdPw))
                                        }
                                    })
                                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2 - 88, alignment: .leading)
                                Button(action: {
                                    //아이디 중복 확인 버튼
                                    vm.checkDuplication(email: id) //api 통신
                                    if vm.duplicate {
                                        self.checkInfo[1] = 4
                                    }
                                }){
                                    Text("중복 확인")
                                        .padding()
                                        .font(.system(size: 12, weight: .semibold))
                                        .frame(width: 80, height: 32, alignment: .center)
                                        .foregroundColor(Color.white)
                                        .background(Color("main_accent"))
                                        .cornerRadius(8)
                                }
                            }
                            Divider()
                                .foregroundColor(.gray_bold)
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        }
                        Text(toastMessages[checkInfo[1]]!) //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(.red_error)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                    }
                    VStack{ //비밀번호 입력창
                        HStack{
                            Text("비밀번호")
                                .font(.system(size: 20, weight: .semibold))
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        TextField("비밀번호를 입력하세요", text: $pw)
                            .keyboardType(.asciiCapable)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                            .onSubmit {
                                //fail -> 영어만 있거나 숫자만 있는 경우 || 5보다 작은 문자열 길이
                                let countLetter = pw.filter({$0.isLetter}).count //영어 개수
                                print(countLetter)
                                let countNumber = pw.filter({$0.isNumber}).count //숫자 개수
                                print(countNumber)
                                if countNumber == 0 || countLetter == 0 || 1...4 ~= pw.count {
                                    self.checkInfo[2] = 6
                                }
                                //0자 입력시
                                else if pw.isEmpty {
                                    self.checkInfo[2] = 5
                                }
                                else {
                                    self.checkInfo[2] = 9
                                }
                            }
                            .onReceive(Just(pw), perform: { _ in  //최대 15글자
                                if maxIdPw < pw.count {
                                    pw = String(pw.prefix(maxIdPw))
                                }
                            })
                        Divider()
                            .foregroundColor(.gray_bold)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        Text(toastMessages[checkInfo[2]]!) //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(.red_error)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                    }
                    VStack{ //비밀번호 확인 입력창
                        HStack{
                            Text("비밀번호 확인")
                                .font(.system(size: 20, weight: .semibold))
                            Text("*")
                                .foregroundColor(.blue_bold)
                                .padding(.leading, -2)
                        }
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        TextField("비밀번호 확인을 입력하세요", text: $checkPW)
                            .keyboardType(.asciiCapable)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                            .onSubmit {
                                if pw != checkPW {
                                    self.checkInfo[3] = 7
                                }
                                else if checkPW.isEmpty {
                                    self.checkInfo[3] = 8
                                }
                                else {
                                    self.checkInfo[3] = 9
                                }
                            }
                        Divider()
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                        Text(toastMessages[checkInfo[3]]!) //관련 에러 메세지 따로 출력되도록
                            .font(.caption)
                            .foregroundColor(.red_error)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 8) * 2, alignment: .leading)
                    }
                    Spacer()
                }
                .ignoresSafeArea(.keyboard)
                //모두 올바른 입력값인 경우 회원가입 성공 -> HomeView 이동
                //실패하면 버튼 클릭 x -> 비활성화하면 어떨지
                //우선 상관없이 바로 HomeView 이동 가능하도록
                VStack{
                    Spacer()
                    Button(action:{
                        if username.isEmpty {
                            self.checkInfo[0] = 1
                        }
                        if id.isEmpty {
                            self.checkInfo[1] = 3
                        }
                        if pw.isEmpty {
                            self.checkInfo[2] = 5
                        }
                        if checkPW.isEmpty {
                            self.checkInfo[3] = 8
                        }
                        if isValidSignUp() { //회원가입 모든 조건 통과
                            movingToSignUp = false //LoginView로 이동 -> 위 코드랑 같이 조건 체크 통과시에만
                            //모든 조건 통과한 경우에만 POST 통신
                            vm.postSignUp(email: id, password: pw, name: username) //📡 SignUp API
                        }
                    }){
                        Text("회원가입")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width / 2.2, height: 44, alignment: .center)
                            .foregroundColor(Color.white)
                            .background(Color("main_accent"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, -30)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .center)
        .navigationBarTitle("",displayMode: .inline)
        .background(.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    func isValidSignUp() -> Bool { //전체 조회
        return !username.isEmpty && !id.isEmpty && !pw.isEmpty && !checkPW.isEmpty && checkInfo[0] == 9 && checkInfo[1] == 9 && checkInfo[2] == 9 && checkInfo[3] == 9
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(movingToSignUp: .constant(true))
            .environmentObject(ScrapViewModel())
    }
}
