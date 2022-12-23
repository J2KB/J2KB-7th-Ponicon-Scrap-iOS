//
//  MainHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

//로그인이 된 상태라면, 앱의 처음 시작은 HomeView
//사용자가 저장한 자료를 보거나 수정, 삭제할 수 있는 공간

import SwiftUI

struct MainHomeView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    @State private var isShowingCategorySideMenuView = false
    @State private var isShowingMyPageView = false
    @State private var isPresentDataModalSheet = false
    @State private var selectedCategoryID = 0
    @State private var selectedCategoryOrder = 0
    
    var categoryTitle : String { return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selectedCategoryID}) ?? 0].name)"}
    
    var body: some View {
        ZStack{
            //Main Home
            NavigationView{
                SubHomeView(datas: $scrapVM.dataList, isPresentDataModalSheet: $isPresentDataModalSheet, currentCategoryId: $selectedCategoryID, currentCategoryOrder: $selectedCategoryOrder)
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading){
                            HStack(spacing: 2){
                                Button(action: {
                                    if !isPresentDataModalSheet { // -> modal sheet가 열려있으면 카테고리뷰를 열 수 없다
                                        withAnimation(.spring()){
                                            self.isShowingCategorySideMenuView = true
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
                                NavigationLink(destination: MyPageView(userData: $scrapVM.user, isShowingMyPage: $isShowingMyPageView).navigationBarHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowingMyPageView) {
                                    Button(action: {
                                        if !isPresentDataModalSheet { //modal sheet가 열려있으면 마이페이지뷰를 열 수 없다
                                            self.isShowingMyPageView.toggle()
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
            SideMenuView(categoryList: $scrapVM.categoryList.result, isShowingCategoryView: $isShowingCategorySideMenuView, selectedCategoryId: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder)
                .offset(x: isShowingCategorySideMenuView ? 0 : -UIScreen.main.bounds.width)
        }
        .onAppear{
            userVM.userIndex = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") == Optional(0) ?
                                userVM.userIndex : UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") as! Int
            scrapVM.getCategoryListData(userID: userVM.userIndex) //카테고리 조회 통신 📡
            scrapVM.getAllData(userID: userVM.userIndex) //자료 조회 통신 📡 case01
            scrapVM.getMyPageData(userID: userVM.userIndex) //마이페이지 데이터 조회 통신 📡
        }
        .gesture(DragGesture().onEnded({
            if !isShowingMyPageView, !isPresentDataModalSheet {
                if $0.translation.width < -100 {
                    withAnimation(.easeInOut) {
                        self.isShowingCategorySideMenuView = false
                    }
                }
               else if $0.translation.width > 100 {
                    withAnimation(.easeInOut) {
                        self.isShowingCategorySideMenuView = true
                    }
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
    }
}
