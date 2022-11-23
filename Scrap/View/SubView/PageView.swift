//
//  PageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import UniformTypeIdentifiers

struct PageView: View {
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @Binding var data : DataResponse.Datas
    @Binding var isOneCol : Bool
    @State private var height = 200
    @Binding var isPresentHalfModal : Bool
    @State private var isShowMovingCategory = false
    @Binding var currentCategory : Int
    @Binding var currentCatOrder : Int
    @Environment(\.colorScheme) var scheme //Light/Dark mode

    var body: some View {
        VStack(spacing: 0){
            if data.imgUrl == "" || data.imgUrl == nil { //image 없으면 default color
                VStack(spacing: -2){
                    if let urlString = data.link {          //urlString = 자료 링크
                        let url = URL(string: urlString)    //URL값으로 변경
                        if let Url = url {                  //URL값이 nil이 아니면
                            Link(destination: Url, label:{
                                Rectangle()
                                    .foregroundColor(scheme == .light ? .light_blue : .black_bold)
                                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 12, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.6)
                                    .cornerRadius(10, corners: .topLeft)
                                    .cornerRadius(10, corners: .topRight)
                                    .shadow(radius: 2)
                            })
                        }
                    }
                    ZStack{ //정보칸
                        Rectangle()
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 12, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 5) : (UIScreen.main.bounds.width / 2.5) / 2.3)
                            .foregroundColor(scheme == .light ? .white : .black_accent)
                            .cornerRadius(10, corners: .bottomLeft)
                            .cornerRadius(10, corners: .bottomRight)
                            .shadow(radius: 2)
                        VStack(spacing: 2){
                            Text(data.title ?? "")
                                .lineLimit(2)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(scheme == .light ? .black : .white)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 80 : UIScreen.main.bounds.width / 2.8, height: 40, alignment: .topLeading)
                                .padding(.trailing, isOneCol ? 30 : 20)
                            Text(data.domain ?? "") //출처 -> link에서 자르기
                                .font(.caption)
                                .foregroundColor(scheme == .light ? .gray_sub : .blur_gray)
                                .lineLimit(1)
                                .padding(.horizontal, 5)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 12, alignment: .leading)
                        }
                        Button(action: {
                            self.isPresentHalfModal = true //half-modal view 등장
                        }){
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(scheme == .light ? .black_bold : .blur_gray)
                        }
                        .padding(EdgeInsets(top: 0, leading: isOneCol ? 310 : 240, bottom: 34, trailing: isOneCol ? 0 : 100))
                    }
                }
            }
            else { //image가 nil 혹은 ""가 아닌 경우
                VStack(spacing: -2){
                    ZStack { //이미지칸
                        Rectangle()
                            .foregroundColor(scheme == .light ? .light_blue : .black_bold)
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 12, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.6)
                            .cornerRadius(10, corners: .topLeft)
                            .cornerRadius(10, corners: .topRight)
                            .shadow(radius: 2)
                        if let urlString = data.link {
                            let url = URL(string: urlString)
                            if let Url = url {
                                Link(destination: Url, label:{
                                    Image(systemName: "rectangle.fill")
                                        .imageData(url: URL(string: data.imgUrl ?? "")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 12, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.6)
                                        .cornerRadius(10, corners: .topLeft)
                                        .cornerRadius(10, corners: .topRight)
                                })
                            }
                        }
                    }
                    ZStack{ //정보칸
                        Rectangle()
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 12, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 5) : (UIScreen.main.bounds.width / 2.5) / 2.3)
                            .foregroundColor(scheme == .light ? .white : .black_accent)
                            .cornerRadius(10, corners: .bottomLeft)
                            .cornerRadius(10, corners: .bottomRight)
                            .shadow(radius: 2)
                        VStack(spacing: 2){
                            Text(data.title ?? "")
                                .lineLimit(2)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(scheme == .light ? .black : .white)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 80 : UIScreen.main.bounds.width / 2.8, height: 40, alignment: .topLeading)
                                .padding(.trailing, isOneCol ? 30 : 20)
                            Text(data.domain ?? "")
                                .font(.caption)
                                .foregroundColor(scheme == .light ? .gray_sub : .blur_gray)
                                .lineLimit(1)
                                .padding(.horizontal, 5)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 12, alignment: .leading)
                        }
                        Button(action: {
                            isPresentHalfModal = true //half-modal view 등장
                        }){
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(scheme == .light ? .black_bold : .blur_gray)
                        }
                        .padding(EdgeInsets(top: 0, leading: isOneCol ? 310 : 240, bottom: 34, trailing: isOneCol ? 0 : 100))
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentHalfModal){
            HalfSheet {
                VStack{
                    Text(data.title ?? "")
                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                        .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                    List {
                        Section {
                            Button(action:{
                                UIPasteboard.general.setValue(data.link ?? "", forPasteboardType: UTType.plainText.identifier)
                                isPresentHalfModal = false
                            }){
                                Label("링크 복사", systemImage: "doc.on.doc")
                                    .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                            }
                        }
                        .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
                        Section {
                            if currentCatOrder != 0 { //전체 자료는 카테고리 이동 불가
                                Button(action: {
                                    isPresentHalfModal = false
                                    self.isShowMovingCategory = true
                                }) {
                                    NavigationLink(destination: MoveCategoryView(categoryList: $vm.categoryList.result, data: $data, currentCategory: $currentCategory).navigationBarBackButtonHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowMovingCategory){
                                        Label("카테고리 이동", systemImage: "arrow.turn.down.right")
                                            .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                                    }
                                }
                            }
                            Button(action:{
                                vm.deleteData(userID: userVM.userIdx, linkID: data.linkId!)
                                vm.removeData(linkID: data.linkId!)
                                isPresentHalfModal = false
                            }){
                                Label("삭제", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
                    }
                    .background(scheme == .light ? Color("background") : .black_bg)

                }
                .padding(.top, 48)
                .background(scheme == .light ? Color("background") : .black_bg)
            }
            .ignoresSafeArea()
        }
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허남도일! 이름도 참 잘지었어 유명한 이름도 진짜 독특하고 잘지은듯 유명한 탐정 유명한!ㅋㅋㅋㅋ", domain: "naver.com", imgUrl: /*"https://img1.daumcdn.net/thumb/R800x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbWD4nB%2FbtqDTkNXVOo%2Fl9GRUtr0TmblyFySCOpam0%2Fimg.png"*/"")), isOneCol: .constant(true), isPresentHalfModal: .constant(false), currentCategory: .constant(0), currentCatOrder: .constant(1))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

extension Image {
    func imageData(url: URL) -> Self {
        if let data = try? Data(contentsOf: url){
            return Image(uiImage: UIImage(data: data)!)
        }
        return self
    }
}
