//
//  HomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

//로그인이 된 상태라면, 앱의 처음 시작은 HomeView
//사용자가 저장한 자료를 보거나 수정, 삭제할 수 있는 공간

import SwiftUI

struct MainHomeView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel //ScrapApp에서 연결받은 EnvironmentObject
    @EnvironmentObject var userVM : UserViewModel //ScrapApp에서 연결받은 EnvironmentObject
    @State private var isShowingCategory = false
    @State private var isShowingMyPage = false
    @State private var isPresentHalfModal = false //sheet가 열려있는지 체크하기 위한 변수
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @State private var selected = -1 /*UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "lastCategory") ?? */ //last category id 가져오기
    @State private var selectedOrder = 0
    //만약 categoryList안에 아무것도 없다면 전체 자료를 나타내야 됨
    var categoryTitle : String { return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selected}) ?? 0].name)"}
    
    var body: some View {
        ZStack{
            //Main Home
            NavigationView{
                if scrapVM.isLoading == .loading { //서버통신(로딩)중이면 progress view 등장(loading indicator)
                    ProgressView()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                        .background(Color("background"))
                        .ignoresSafeArea()
                }else {
                    SubHomeView(datas: $scrapVM.dataList.result, isPresentHalfModal: $isPresentHalfModal, currentCategory: $selected, currentCategoryOrder: $selectedOrder)
                        .navigationBarTitle("", displayMode: .inline)
                        .toolbar{
                            ToolbarItem(placement: .navigationBarLeading){
                                HStack(spacing: 2){
                                    Button(action: {
                                        if !isPresentHalfModal {                        //modal sheet가 열려있으면 카테고리뷰를 열 수 없다
                                            withAnimation(.spring()){
                                                self.isShowingCategory = true
                                            }
                                        }
                                    }) {
                                        Image(systemName: "line.3.horizontal")
                                            .resizable()
                                            .frame(width: 20, height: 14)
                                            .foregroundColor(Color("basic_text"))
                                    }
                                    Text(categoryTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("basic_text"))
                                }
                            }
                        }
                        .toolbar{
                            ToolbarItem(placement: .navigationBarTrailing){
                                VStack{
                                    NavigationLink(destination: MyPageView(userData: $scrapVM.user.result, isShowingMyPage: $isShowingMyPage).navigationBarHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowingMyPage) {
                                        Button(action: {                                //modal sheet가 열려있으면 마이페이지뷰를 열 수 없다
                                            if !isPresentHalfModal {
                                                self.isShowingMyPage.toggle()
                                            }
                                        }) {
                                            Image(systemName: "person.circle")
                                                .foregroundColor(Color("basic_text"))
                                        }
                                    }
                                }
                            }
                        }
                }
            }
            //Drawer
            SideMenuView(categoryList: $scrapVM.categoryList.result, isShowingCateogry: $isShowingCategory, selected: $selected, selectedOrder: $selectedOrder)
                .offset(x: isShowingCategory ? 0 : -UIScreen.main.bounds.width - 5)
        }
        .background(Color("background"))
        .onAppear{ //MainHomeView 등장하면 api 통신
            scrapVM.isLoading = .loading
            userVM.userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") == Optional(0) ? userVM.userIdx : UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") as! Int
            scrapVM.getCategoryData(userID: userVM.userIdx) //카테고리 조회 통신 📡
            scrapVM.getMyPageData(userID: userVM.userIdx) //마이페이지 데이터 조회 통신 📡
            if self.selected == 0 { scrapVM.getAllData(userID: userVM.userIdx) } //자료 조회 통신 📡 case01
            else { scrapVM.getData(userID: userVM.userIdx, catID: selected) } //자료 조회 통신 📡 case02
        }
//        .task{
//            await scrapVM.whenMainHomeAppear(selected: selected, userIdx: userVM.userIdx)
//            scrapVM.getCategoryData(userID: userVM.userIdx) //카테고리 조회 통신 📡
//            scrapVM.getMyPageData(userID: userVM.userIdx) //마이페이지 데이터 조회 통신 📡
//            if self.selected == 0 { scrapVM.getAllData(userID: userVM.userIdx) } //자료 조회 통신 📡 case01
//            else { scrapVM.getData(userID: userVM.userIdx, catID: selected, seq: "seq") } //자료 조회 통신 📡 case02
//        }
        .gesture(DragGesture().onEnded({
             if $0.translation.width < -100 {
                 withAnimation(.easeInOut) {
                     self.isShowingCategory = false
                 }
             }
            else if $0.translation.width > 100 {
                 withAnimation(.easeInOut) {
                     self.isShowingCategory = true
                 }
             }
         }))
    }
}

struct MainHomeView_Previews: PreviewProvider { 
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
