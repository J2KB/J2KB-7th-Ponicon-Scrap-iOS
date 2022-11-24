//
//  PageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import UniformTypeIdentifiers

struct PageView: View {
    @Environment(\.colorScheme) var scheme              //Light/Dark mode
    @EnvironmentObject var vm : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    @Binding var isPresentHalfModal : Bool              //카테고리 더보기 sheet가 열려있는지에 대한 상태 변수
//    @State private var isShowMovingCategory = false     //카테고리 이동을 위해 view를 열었는지에 대한 상태 변수
    @Binding var data : DataResponse.Datas              //해당 자료 데이터
    @Binding var detailData : DataResponse.Datas
    @Binding var isOneCol : Bool                        //1열인가?
    @Binding var currentCategory : Int                  //현재 카테고리 id
    @Binding var currentCatOrder : Int                  //현재 카테고리 order

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
                        Button(action: {                     //더보기 버튼 클릭하면 isPresentHalfModal = true, sheet 올라옴
                            isPresentHalfModal = true        //half-modal view 등장
                            print("✅ page view에서 더보기 버튼을 누름")
                            detailData = data
                            print(data.linkId)
                            print(data.title)
                            print(data.imgUrl)
                            print(data.domain)
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
                        Button(action: {                //더보기 버튼 클릭하면 isPresentHalfModal = true, sheet 올라옴
                            isPresentHalfModal = true   //half-modal view 등장
                            detailData = data
                            print("✅ page view에서 더보기 버튼을 누름")
                            print(data.linkId)
                            print(data.title)
                            print(data.imgUrl)
                            print(data.domain)
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
        .onAppear{   //pageView가 등장
            print("⭐️⭐️⭐️\(data.title)의 pageView 등장⭐️⭐️⭐️")
//            UITableView.appearance().backgroundColor = .clear
        }
//        .sheet(isPresented: $isPresentHalfModal){
//            HalfSheet {
//                VStack{
//                    Text(data.title ?? "")
//                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
//                        .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
//                    List {
//                        Section {
//                            Button(action:{
//                                UIPasteboard.general.setValue(data.link ?? "", forPasteboardType: UTType.plainText.identifier)
//                                isPresentHalfModal = false
//                            }){
//                                Label("링크 복사", systemImage: "doc.on.doc")
//                                    .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
//                            }
//                        }
//                        .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
//                        Section {
//                            if currentCatOrder != 0 { //전체 자료는 카테고리 이동 불가
//                                Button(action: {
//                                    isPresentHalfModal = false
//                                    self.isShowMovingCategory = true
//                                    print("isShowMovingCategory true!")
//                                }) {
//                                    NavigationLink(destination: MoveCategoryView(categoryList: $vm.categoryList.result, data: $data, currentCategory: $currentCategory).navigationBarBackButtonHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowMovingCategory){
//                                        Label("카테고리 이동", systemImage: "arrow.turn.down.right")
//                                            .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
//                                    }
//                                }
//                            }
//                            Button(action:{
//                                vm.deleteData(userID: userVM.userIdx, linkID: data.linkId!)
//                                vm.removeData(linkID: data.linkId!)
//                                isPresentHalfModal = false
//                            }){
//                                Label("삭제", systemImage: "trash")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                        .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
//                    }
//                    .background(scheme == .light ? Color("background") : .black_bg)
//
//                }
//                .padding(.top, 48)
//                .background(scheme == .light ? Color("background") : .black_bg)
//            }
//            .ignoresSafeArea()
//        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(
            isPresentHalfModal: .constant(false),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허남도", domain: "naver.com", imgUrl: "")),
            detailData: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "", domain: "naver.com", imgUrl: "")), isOneCol: .constant(true),
            currentCategory: .constant(0),
            currentCatOrder: .constant(1)
        )
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
