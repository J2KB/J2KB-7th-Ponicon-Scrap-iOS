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
//    @Binding var autoLogin : Bool
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @State private var selected = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "lastCategory") ?? 0 //last category id 가져오기
    
    //만약 categoryList안에 아무것도 없다면 전체 자료를 나타내야 됨
    var categoryTitle : String {
        return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selected}) ?? 0].name)"
    }
    
    var body: some View {
        ZStack{
            //Main Home
            NavigationView{
                SubHomeView(datas: $scrapVM.dataList.result, currentCategory: $selected) //⭐️여기로 category 데이터 넘겨줘야 됨
                .navigationBarTitle("", displayMode: .inline)
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        HStack(spacing: 2){
                            Button(action: {
                                withAnimation(.easeInOut.delay(0.3)){
                                    self.isShowingCategory = true
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 20, height: 14)
                                    .foregroundColor(scheme == .light ? .black : .gray_sub)
                            }
                            Text(categoryTitle)
                                .fontWeight(.bold)
                        }
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        VStack{
                            NavigationLink(destination: MyPageView(userData: $scrapVM.user.result, isShowingMyPage: $isShowingMyPage).navigationBarHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowingMyPage) {
                                Button(action: {
                                    self.isShowingMyPage.toggle()
                                    scrapVM.getMyPageData(userID: userVM.userIdx)
                                }) {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(scheme == .light ? .black : .gray_sub)
                                }
                            }
                        }
                    }
                }
            }
            //Drawer
            SideMenuView(categoryList: $scrapVM.categoryList.result, isShowingCateogry: $isShowingCategory, selected: $selected)
                .offset(x: isShowingCategory ? 0 : -UIScreen.main.bounds.width - 5)
        }
        .background(scheme == .light ? .white : .black_bg)
        .onAppear{ //MainHomeView 등장하면 api 통신
            userVM.userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") == Optional(0) ? userVM.userIdx : UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") as! Int
            scrapVM.getCategoryData(userID: userVM.userIdx)
            if self.selected == 0 {
            scrapVM.getAllData(userID: userVM.userIdx)
            } else {
                scrapVM.getData(userID: userVM.userIdx, catID: selected, seq: "seq")
            }
            print("🚨🚨Main Home View 나타남🚨🚨")
        }
//        .gesture(DragGesture().onEnded({
//            if $0.translation.width < -100 {
//                withAnimation(.easeInOut) {
//                    self.isShowingCategory = false
//                }
//            }else if $0.translation.width > 100 {
//                withAnimation(.easeInOut) {
//                    self.isShowingCategory = true
//                }
//            }
//        }))
    }
}

struct MainHomeView_Previews: PreviewProvider { 
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
//            .preferredColorScheme(.dark)
    }
}
