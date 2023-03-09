//
//  TabView.swift
//  Scrap
//
//  Created by 김영선 on 2023/02/23.
//

import SwiftUI

struct TabControlView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel

    var body: some View {
        TabView {
            MainHomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("홈")
                }
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("즐겨찾기")
                }
            MyPageView(userData: $scrapVM.user)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("마이페이지")
                }
        }
        .accentColor(Color("main_accent"))
        .onAppear{
            userVM.userIndex = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") == Optional(0) ?
                                userVM.userIndex : UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") as! Int
            scrapVM.getCategoryListData(userID: userVM.userIndex) //카테고리 조회 통신 📡
            scrapVM.getAllData(userID: userVM.userIndex) //자료 조회 통신 📡
            scrapVM.getMyPageData(userID: userVM.userIndex) //마이페이지 데이터 조회 통신 📡
        }
    }
}

struct TabControlView_Previews: PreviewProvider {
    static var previews: some View {
        TabControlView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
