//
//  ScrapApp.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI

@main
struct ScrapApp: App {
    @StateObject var scrapVM = ScrapViewModel()
    @StateObject var userVM = UserViewModel()

    var body: some Scene {
        WindowGroup {
            //if 로그아웃 혹은 첫 런칭이라면 LoginView()
            //else HomeView()
//            RootView()
//            MainHomeView()
//                .environmentObject(scrapVM)
//                .environmentObject(userVM)
            LoginView()
                .environmentObject(scrapVM)
                .environmentObject(userVM)
        }
    }
}
