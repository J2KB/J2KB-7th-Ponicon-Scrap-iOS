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
    
    func isValidURL(url: String?) -> Bool {
        guard url != "" else { return false } //비어있으면"" -> return false
        guard url != " " else { return false }
        guard url != nil else { return false }
        if url!.range(of: "[가-힣]", options: .regularExpression) != nil { return false } //한국어가 들어감
        return true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !isValidURL(url: data.imgUrl) { //image 없으면 default color
                VStack(spacing: -2){
                    if let urlString = data.link {          //urlString = 자료 링크
                        let url = URL(string: urlString)    //URL값으로 변경
                        if let Url = url {                  //URL값이 nil이 아니면
                            Link(destination: Url, label: {
                                Rectangle()
                                    .foregroundColor(Color("image"))
                                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 20 : UIScreen.main.bounds.width / 2.2, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.4 : (UIScreen.main.bounds.width / 2.5) / 1.6)
                                    .cornerRadius(10, corners: .topLeft)
                                    .cornerRadius(10, corners: .topRight)
                                    .shadow(radius: 2)
                            })
                        }
                    }
                    ZStack{ //정보칸
                        Rectangle()
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 20 : UIScreen.main.bounds.width / 2.2, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 5) : (UIScreen.main.bounds.width / 2.5) / 2.3)
                            .foregroundColor(Color("data_bottom"))
                            .cornerRadius(10, corners: .bottomLeft)
                            .cornerRadius(10, corners: .bottomRight)
                            .shadow(radius: 2)
                        VStack(spacing: 2){
                            Text(data.title ?? "")
                                .lineLimit(2)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("basic_text"))
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 60 : UIScreen.main.bounds.width / 2.8, height: 40, alignment: .topLeading)
                                .padding(.trailing, UIScreen.main.bounds.width / 15)
                            Text(data.domain ?? "") //출처 -> link에서 자르기
                                .font(.caption)
                                .foregroundColor(Color("domain_color"))
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 24 : UIScreen.main.bounds.width / 2.2, alignment: .leading)
                        }
                        Button(action: {                     //더보기 버튼 클릭하면 isPresentHalfModal = true, sheet 올라옴
                            isPresentHalfModal = true        //half-modal view 등장
                            detailData = data
                        }){
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(Color("option_button"))
                        }
                        .padding(EdgeInsets(top: 0, leading: isOneCol ? UIScreen.main.bounds.width - 60 : UIScreen.main.bounds.width - 136, bottom: UIScreen.main.bounds.width / 12, trailing: isOneCol ? 0 : UIScreen.main.bounds.width / 3.8))
                    }
                }
            }
            else { //image가 nil 혹은 ""가 아닌 경우
                VStack(spacing: -2){
                    ZStack { //이미지칸
                        Rectangle()
                            .foregroundColor(Color("image"))
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 20 : UIScreen.main.bounds.width / 2.2, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.4 : (UIScreen.main.bounds.width / 2.5) / 1.6)
                            .cornerRadius(10, corners: .topLeft)
                            .cornerRadius(10, corners: .topRight)
                            .shadow(radius: 2)
                        if let urlString = data.link {
                            let url = URL(string: urlString)
                            if let Url = url {
                                Link(destination: Url, label: {
                                    AsyncImage(url: URL(string: data.imgUrl!)!) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 20 : UIScreen.main.bounds.width / 2.2, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.4 : (UIScreen.main.bounds.width / 2.5) / 1.6)
                                    .cornerRadius(10, corners: .topLeft)
                                    .cornerRadius(10, corners: .topRight)
                                })
                            }
                        }
                    }
                    ZStack{ //정보칸
                        Rectangle()
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 20 : UIScreen.main.bounds.width / 2.2, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 4.8) : (UIScreen.main.bounds.width / 2.5) / 2.3)
                            .foregroundColor(Color("data_bottom"))
                            .cornerRadius(10, corners: .bottomLeft)
                            .cornerRadius(10, corners: .bottomRight)
                            .shadow(radius: 2)
                        VStack(spacing: 2) {
                            Text(data.title ?? "")
                                .lineLimit(2)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("basic_text"))
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 60 : UIScreen.main.bounds.width / 2.8, height: 40, alignment: .topLeading)
                                .padding(.trailing, UIScreen.main.bounds.width / 15)
                            Text(data.domain ?? "")
                                .font(.caption)
                                .foregroundColor(Color("domain_color"))
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 24 : UIScreen.main.bounds.width / 2.2, alignment: .leading)
                        }
                        Button(action: {                //더보기 버튼 클릭하면 isPresentHalfModal = true, sheet 올라옴
                            isPresentHalfModal = true   //half-modal view 등장
                            detailData = data
                        }){
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(Color("option_button"))
                        }
                        .padding(EdgeInsets(top: 0, leading: isOneCol ? UIScreen.main.bounds.width - 60 : UIScreen.main.bounds.width - 136, bottom: UIScreen.main.bounds.width / 12, trailing: isOneCol ? 0 : UIScreen.main.bounds.width / 3.8))
                    }
                }
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(
            isPresentHalfModal: .constant(false),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허남도", domain: "naver.com", imgUrl:"" /*"http://static1.squarespace.com/static/5e9672644b617e2a1765d11c/t/5eddc91b1cb53938998c7a67/1591593250119/Codable+Crash+Data+Missing.png?format=1500w"*/)),
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
