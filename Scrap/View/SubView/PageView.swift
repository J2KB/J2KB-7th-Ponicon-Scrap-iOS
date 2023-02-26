//
//  PageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import UniformTypeIdentifiers

struct PageView: View {
    @Binding var isPresentDataModalSheet : Bool         //카테고리 더보기 sheet가 열려있는지에 대한 상태 변수
    @Binding var data : DataResponse.Datas              //해당 자료 데이터
    @Binding var detailData : DataResponse.Datas
    @Binding var isOneColumnData : Bool                 //1열인가?
    @Binding var currentCategoryId : Int                //현재 카테고리 id
    @Binding var currentCategoryOrder : Int             //현재 카테고리 order
    
    private let screenHeight = UIScreen.main.bounds.height
    private let screenWidth = UIScreen.main.bounds.width
    
    private func isValidURL(url: String?) -> Bool {
        guard url != "" else { return false }
        guard url != " " else { return false }
        guard url != nil else { return false }
        if url!.range(of: "[가-힣]", options: .regularExpression) != nil { return false } //한국어가 들어감
        return true
    }
    
    var body: some View {
        VStack(spacing: -2) {
            LinkImageView
            InformationView
        }
    }
    //body
    
    var LinkImageView: some View {
        VStack{
            //Link Image Part
            if let urlString = data.link {          //자료 링크 -> 옵셔널 바인딩
                let url = URL(string: urlString)    //URL값으로 변경
                if let Url = url {                  //URL값이 nil이 아니면
                    ZStack{
                        //image 없으면 default color
                        if !isValidURL(url: data.imgUrl) {
                            Link(destination: Url, label: {
                                Rectangle()
                                    .foregroundColor(Color("image"))
                                    .frame(width: isOneColumnData ? screenWidth / 1.085 : screenWidth / 2.4, height: isOneColumnData ? screenWidth / 3.2 : screenWidth / 4.4)
                                    .cornerRadius(10, corners: .topLeft)
                                    .cornerRadius(10, corners: .topRight)
                                    .shadow(radius: 2)
                            })
                        }
                        //image가 nil 혹은 ""가 아닌 경우
                        else {
                            Link(destination: Url, label: {
                                AsyncImage(url: URL(string: data.imgUrl!)!) { phase in
                                    if let image = phase.image {
                                        image // Displays the loaded image.
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else if phase.error != nil {
                                        Color("image") // Indicates an error.
                                    } else {
                                        ProgressView() // Acts as a placeholder.
                                    }
                                }
                                .frame(width: isOneColumnData ? screenWidth / 1.085 : screenWidth / 2.4, height: isOneColumnData ? screenWidth / 3.2 : screenWidth / 4.4)
                                .cornerRadius(10, corners: .topLeft)
                                .cornerRadius(10, corners: .topRight)
                                .shadow(radius: 2)
                            })
                        }
                        VStack{
                            Button(action: {
                                //즐겨찾기 기능
                            }){
                                ZStack{
                                    Image(systemName: "heart.fill") //즐겨찾기포함이라면 "heart.fill"
                                        .foregroundColor(Color("heart"))
                                }
                                .frame(width: 30, height: 30)
                            }
                            .padding(.leading, isOneColumnData ? screenWidth / 1.22 : screenWidth / 3)
                            .padding(.bottom, isOneColumnData ? screenWidth / 5 : screenWidth / 7.6)
                        }
                        .frame(width: isOneColumnData ? screenWidth / 1.085 : screenWidth / 2.4, height: isOneColumnData ? screenWidth / 3.2 : screenWidth / 4.4)
                        .shadow(radius: 5)
                    }
                }
            }
        }
    }
    
    var InformationView : some View {
        //Infomation Part
        ZStack{
            Rectangle()
                .frame(width: isOneColumnData ? screenWidth / 1.085 : screenWidth / 2.4, height: isOneColumnData ? screenWidth / 5 : screenWidth / 5.52)
                .foregroundColor(Color("data_bottom"))
                .cornerRadius(10, corners: .bottomLeft)
                .cornerRadius(10, corners: .bottomRight)
                .shadow(radius: 2)
            
            VStack(spacing: 10){
                HStack{
                    Text(data.title ?? "")
                        .frame(width: isOneColumnData ? screenWidth / 1.22 : screenWidth / 2.8, height: isOneColumnData ? screenWidth / 10 : screenWidth / 12, alignment: .topLeading)
                        .lineLimit(2)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.leading, isOneColumnData ? 6 : 4)
                    Spacer()
                }
                .frame(width: isOneColumnData ? screenWidth / 1.085 : screenWidth / 2.4)

                Text(data.domain ?? "")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(Color("domain_color"))
                    .lineLimit(1)
                    .frame(width: isOneColumnData ? screenWidth / 1.085 : screenWidth / 2.4, alignment: .leading)
                    .padding(.leading, isOneColumnData ? 14 : 10)
            }
            .frame(width: isOneColumnData ? screenWidth / 1.085 : screenWidth / 2.4, height: isOneColumnData ? screenWidth / 5 : screenWidth / 5.52)
            
            Button(action: {                     //더보기 버튼 클릭하면 isPresentHalfModal = true, sheet 올라옴
                isPresentDataModalSheet = true   //half-modal view 등장
                detailData = data
            }, label: {
                ZStack{
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(Color("option_button"))
                }
                .frame(width: isOneColumnData ? 40 : 25, height: 40)
            })
            .padding(EdgeInsets(top: 0, leading: isOneColumnData ? screenWidth / 1.18 : screenWidth / 1.6, bottom: isOneColumnData ? screenWidth / 10 : screenWidth / 12, trailing: isOneColumnData ? 0 : screenWidth / 3.8))
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(
            isPresentDataModalSheet: .constant(false),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허남도일~ 보고싶다!히히", domain: "naver.com", imgUrl:"")),
            detailData: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "", domain: "naver.com", imgUrl: "")), isOneColumnData: .constant(false),
            currentCategoryId: .constant(0),
            currentCategoryOrder: .constant(1)
        )
        .environmentObject(ScrapViewModel())
        .environmentObject(UserViewModel())
        PageView(
            isPresentDataModalSheet: .constant(false),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허남도일~", domain: "naver.com", imgUrl: "http://static1.squarespace.com/static/5e9672644b617e2a1765d11c/t/5eddc91b1cb53938998c7a67/1591593250119/Codable+Crash+Data+Missing.png?format=1500w")),
            detailData: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "", domain: "naver.com", imgUrl: "")), isOneColumnData: .constant(false),
            currentCategoryId: .constant(0),
            currentCategoryOrder: .constant(1)
        )
        PageView(
            isPresentDataModalSheet: .constant(false),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허 남도일~ 보고싶다!히히 코난은 정뫌 재미 있어, 극장판 볼거 짱많은데 할게 너무 많네...ㅋ 밥먹으면서 봐야겠다 흑흑 어쩌면 좋아", domain: "naver.com", imgUrl:"")),
            detailData: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "", domain: "naver.com", imgUrl: "")), isOneColumnData: .constant(true),
            currentCategoryId: .constant(0),
            currentCategoryOrder: .constant(1)
        )
        .environmentObject(ScrapViewModel())
        .environmentObject(UserViewModel())
        PageView(
            isPresentDataModalSheet: .constant(false),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허 남도일~ 보고싶다!히히 코난은 정뫌 재미 있어, 극장판 볼거 짱많은데 할게 너무 많네...ㅋ 밥먹으면서 봐야겠다 흑흑 어쩌면 좋아", domain: "naver.com", imgUrl: "http://static1.squarespace.com/static/5e9672644b617e2a1765d11c/t/5eddc91b1cb53938998c7a67/1591593250119/Codable+Crash+Data+Missing.png?format=1500w")),
            detailData: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "", domain: "naver.com", imgUrl: "")), isOneColumnData: .constant(true),
            currentCategoryId: .constant(0),
            currentCategoryOrder: .constant(1)
        )
        .environmentObject(ScrapViewModel())
        .environmentObject(UserViewModel())

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
