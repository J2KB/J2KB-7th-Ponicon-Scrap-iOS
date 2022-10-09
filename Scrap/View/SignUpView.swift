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
//    @State private var signUpButton = false
    let maxUserName = 30
    let maxIdPw = 15
    @Binding var movingToSignUp : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //pop
    
    let toastMessages = [0 : "한글 또는 영어로만 이뤄질 수 있습니다", 1: "이름을 입력하세요", 2: "5~15자의 영문 소문자, 숫자를 포함해야 합니다", 3: "아이디를 입력하세요", 4: "이미 존재하는 아이디입니다", 5: "비밀번호를 입력하세요", 6: "5~15자의 영어, 숫자를 포함해야 합니다", 7: "비밀번호와 일치하지 않습니다", 8: "비밀번호 확인을 입력하세요", 9: ""] //Dictionary 형태로 메세지 모음
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
    var body: some View {
        VStack(spacing: 32){
            VStack{
                VStack{ //이름 입력창
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
                        .onReceive(Just(username), perform: { _ in  //최대 30글자
                            if maxUserName < username.count {
                                username = String(username.prefix(maxUserName))
                            }
                        })
                    Divider()
                        .foregroundColor(light_gray)
                        .frame(width: UIScreen.main.bounds.width/1.2)
                    Text(toastMessages[checkInfo[0]]!) //관련 에러 메세지 따로 출력되도록
                        .font(.caption)
                        .foregroundColor(error_red)
                        .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                }
                .padding(.bottom, 16)
                VStack{ //아이디 입력창
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
                                .keyboardType(.asciiCapable)
                                .frame(width: UIScreen.main.bounds.width/1.65, height: 28, alignment: .leading)
                                .onSubmit {
                                    //특수문자 들어감 || 영문 대문자가 들어간 경우 || 소문자 혹은 숫자가 없는 경우
                                    let countLetter = id.filter({$0.isLetter}).count
                                    let countNumber = id.filter({$0.isNumber}).count
                                    if id.filter({$0.isUppercase}).count != 0 || countLetter+countNumber != id.count || countNumber == 0 || countLetter == 0 || 1...4 ~= id.count {
                                        self.checkInfo[1] = 2
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
                            Button(action: {
                                //아이디 중복 확인 버튼
                                //api 통신
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
                    Text(toastMessages[checkInfo[1]]!) //관련 에러 메세지 따로 출력되도록
                        .font(.caption)
                        .foregroundColor(error_red)
                        .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                }
                .padding(.bottom, 16)
                VStack{ //비밀번호 입력창
                    HStack{
                        Text("비밀번호")
                            .font(.system(size: 20, weight: .semibold))
                        Text("*")
                            .foregroundColor(bold_blue)
                            .padding(.leading, -2)
                    }
                    .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                    TextField("비밀번호를 입력하세요", text: $pw)
                        .keyboardType(.asciiCapable)
                        .frame(width: UIScreen.main.bounds.width/1.2, height: 28, alignment: .leading)
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
                        .foregroundColor(light_gray)
                        .frame(width: UIScreen.main.bounds.width/1.2)
                    Text(toastMessages[checkInfo[2]]!) //관련 에러 메세지 따로 출력되도록
                        .font(.caption)
                        .foregroundColor(error_red)
                        .frame(width: UIScreen.main.bounds.width/1.2, alignment: .topLeading)
                }
                .padding(.bottom, 16)
                VStack{ //비밀번호 확인 입력창
                    HStack{
                        Text("비밀번호 확인")
                            .font(.system(size: 20, weight: .semibold))
                        Text("*")
                            .foregroundColor(bold_blue)
                            .padding(.leading, -2)
                    }
                    .frame(width: UIScreen.main.bounds.width/1.2, alignment: .leading)
                    TextField("비밀번호 확인을 입력하세요", text: $checkPW)
                        .keyboardType(.asciiCapable)
                        .frame(width: UIScreen.main.bounds.width/1.2, height: 28, alignment: .leading)
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
                        .frame(width: UIScreen.main.bounds.width/1.2)
                    Text(toastMessages[checkInfo[3]]!) //관련 에러 메세지 따로 출력되도록
                        .font(.caption)
                        .foregroundColor(error_red)
                        .frame(width: UIScreen.main.bounds.width/1.2, alignment: .topLeading)
                }
                .padding(.bottom, 16)
            }
            
            //모두 올바른 입력값인 경우 회원가입 성공 -> HomeView 이동
            //실패하면 버튼 클릭 x -> 비활성화하면 어떨지
            //우선 상관없이 바로 HomeView 이동 가능하도록
            Button(action:{
//                if username.isEmpty || id.isEmpty
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
                    vm.postSignUp(userid: id, password: pw, name: username) //모든 조건 통과한 경우에만 POST 통신
                }
            }){
                Text("회원가입")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: UIScreen.main.bounds.width / 2.2, height: 44, alignment: .center)
                    .foregroundColor(Color.white)
                    .background(light_blue)
                    .cornerRadius(10)
            }
            .padding(.top, 28)
        }
        .padding(.bottom, 80)
        .navigationBarTitle("",displayMode: .inline)
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
