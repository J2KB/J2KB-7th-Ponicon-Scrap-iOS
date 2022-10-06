//
//  ScrapApp.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct ScrapApp: App {
    @StateObject var scrapVM = ScrapViewModel()
    @StateObject var userVM = UserViewModel()

    init(){
        KakaoSDK.initSDK(appKey: "7942e72a93d27c86ee00caec504989f7") //native app key
    }
    
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
                .onOpenURL{ url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                          _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
