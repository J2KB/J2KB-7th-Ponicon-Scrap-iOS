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
    @State private var selected = 0
    @State private var selectedOrder = 0
    var categoryTitle : String { return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selected}) ?? 0].name)"}
    
    var body: some View {
        ZStack{
            //Main Home
            NavigationView{
                SubHomeView(datas: $scrapVM.dataList, isPresentHalfModal: $isPresentHalfModal, currentCategory: $selected, currentCategoryOrder: $selectedOrder)
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
                                NavigationLink(destination: MyPageView(userData: $scrapVM.user, isShowingMyPage: $isShowingMyPage).navigationBarHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowingMyPage) {
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
            //Drawer
            SideMenuView(categoryList: $scrapVM.categoryList.result, isShowingCateogry: $isShowingCategory, selected: $selected, selectedOrder: $selectedOrder)
                .offset(x: isShowingCategory ? 0 : -UIScreen.main.bounds.width)
        }
        .onAppear{ //MainHomeView 등장하면 api 통신
            userVM.userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") == Optional(0) ? userVM.userIdx : UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") as! Int
            Task {
                await scrapVM.inquiryCategoryData(userID: userVM.userIdx) //카테고리 조회 통신 📡
            }
            scrapVM.inquiryUserData(userID: userVM.userIdx) //마이페이지 데이터 조회 통신 📡
            if self.selected == 0 { scrapVM.inquiryAllData(userID: userVM.userIdx) } //자료 조회 통신 📡 case01
            else { scrapVM.inquiryData(userID: userVM.userIdx, catID: selected) } //자료 조회 통신 📡 case02
        }
        .gesture(DragGesture().onEnded({
            if !isShowingMyPage, !isPresentHalfModal {
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
            }
         }))
    }
}

struct MainHomeView_Previews: PreviewProvider { 
    static var previews: some View {
        MainHomeView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
//            .preferredColorScheme(.dark)
    }
}
