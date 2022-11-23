//
//  MainHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct SubHomeView: View {
    @State private var isOneCol = true
    @State private var isRecent = true
    @Binding var datas : DataResponse.Result
    @Binding var isPresentHalfModal : Bool
    @Binding var currentCategory : Int
    @Binding var currentCategoryOrder : Int
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    
//    @State private var test = [DataResponse.Datas.init(linkId: 0, link: "https://www.apple.com", title: "명탐정코난보고싶다", domain: "명탐정코난", imgUrl: "https://img1.daumcdn.net/thumb/R800x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbWD4nB%2FbtqDTkNXVOo%2Fl9GRUtr0TmblyFySCOpam0%2Fimg.png"), DataResponse.Datas.init(linkId: 0, link: "https://www.apple.com", title: "명탐정코난보고싶다정말로", domain: "명탐정코난", imgUrl: "https://img1.daumcdn.net/thumb/R800x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbWD4nB%2FbtqDTkNXVOo%2Fl9GRUtr0TmblyFySCOpam0%2Fimg.png"), DataResponse.Datas.init(linkId: 0, link: "https://www.apple.com", title: "명탐정코난보고싶다잠도자고싶다", domain: "명탐정코난", imgUrl: "https://img1.daumcdn.net/thumb/R800x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbWD4nB%2FbtqDTkNXVOo%2Fl9GRUtr0TmblyFySCOpam0%2Fimg.png"), DataResponse.Datas.init(linkId: 0, link: "", title: "명탐정코난보고싶다남도일이름도이뻐", domain: "명탐정코난", imgUrl: "https://img1.daumcdn.net/thumb/R800x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbWD4nB%2FbtqDTkNXVOo%2Fl9GRUtr0TmblyFySCOpam0%2Fimg.png"), DataResponse.Datas.init(linkId: 0, link: "", title: "명탐정코난보고싶다오글거리지만재미잇어", domain: "명탐정코난", imgUrl: "https://img1.daumcdn.net/thumb/R800x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbWD4nB%2FbtqDTkNXVOo%2Fl9GRUtr0TmblyFySCOpam0%2Fimg.png"), DataResponse.Datas.init(linkId: 0, link: "https://www.apple/com", title: "명탐정코난보고싶다진짜졸리다흑흑", domain: "명탐정코난", imgUrl: "")]

    var body: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false){
                HStack{
                    Button(action: {
                        if !isPresentHalfModal {
                            self.isOneCol.toggle()
                        }
                    }){
                        Image(systemName: isOneCol ? "square.grid.2x2.fill" : "line.3.horizontal")
                            .resizable()
                            .frame(width: 16, height: isOneCol ? 16 : 12)
                            .foregroundColor(.gray)
                    }
                    Text(isRecent ? "최신순" : "오래된 순") //정렬 순서에 따라 달라짐 (최신순/오래된순)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Button(action: {
                        if !isPresentHalfModal {
                            self.isRecent.toggle()
                        }
                    }){
                        Image(systemName: "arrow.up.arrow.down")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 32, height: 40, alignment: .trailing)
                LazyVGrid(columns: isOneCol ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: UIScreen.main.bounds.width / 3))], spacing: 10){
                    if isRecent {
                        ForEach($datas.links.reversed()) { data in
//                        ForEach($test) { tt in
                            PageView(data: data, isOneCol: $isOneCol, isPresentHalfModal: $isPresentHalfModal, currentCategory: $currentCategory, currentCatOrder: $currentCategoryOrder)
                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                        }
                    } else {
                        ForEach($datas.links) { data in
                            PageView(data: data, isOneCol: $isOneCol, isPresentHalfModal: $isPresentHalfModal, currentCategory: $currentCategory, currentCatOrder: $currentCategoryOrder)
                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                        }
                    }
                } //LAZYGRID
                .padding(.horizontal, isOneCol ? 0 : 15)
            }//ScrollView
        }//VStack
        .background(scheme == .light ? .white : .black_bg)
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
    }//body
}

struct SubHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
//            .preferredColorScheme(.dark)
    }
}
