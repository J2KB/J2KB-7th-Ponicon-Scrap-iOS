////
////  TabView.swift
////  Scrap
////
////  Created by 김영선 on 2023/02/23.
////
//
//import SwiftUI
//
//struct TabControlView: View {
//    @EnvironmentObject var scrapVM : ScrapViewModel
//    @EnvironmentObject var userVM : UserViewModel
//    
//    @State private var selection = 0
//    
//    init() {
//        UITabBar.appearance().scrollEdgeAppearance = .init()
//    }
//
//    var body: some View {
//        TabView {
//            MainHomeView()
//                .tabItem {
//                    Image(systemName: "house")
//                    Text("홈")
//                }.tag(0)
//            FavoritesView()
//                .tabItem {
//                    Image(systemName: "heart")
//                    Text("즐겨찾기")
//                }.tag(1)
//            MyPageView(userData: $scrapVM.user)
//                .tabItem {
//                    Image(systemName: "person.circle")
//                    Text("마이페이지")
//                }.tag(2)
//        }
//        .onAppear{
//            userVM.userIndex = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") == Optional(0) ?
//                                userVM.userIndex : UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") as! Int
//            scrapVM.getCategoryListData(userID: userVM.userIndex) //카테고리 조회 통신 📡
//            scrapVM.getAllData(userID: userVM.userIndex) //자료 조회 통신 📡
//            scrapVM.getMyPageData(userID: userVM.userIndex) //마이페이지 데이터 조회 통신 📡
//        }
//    }
//}
//
//struct TabControlView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabControlView()
//            .environmentObject(ScrapViewModel())
//            .environmentObject(UserViewModel())
//    }
//}
