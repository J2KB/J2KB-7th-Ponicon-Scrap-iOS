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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var scrapVM = ScrapViewModel()
    @StateObject var userVM = UserViewModel()
    var userIndex : Int { return UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") ?? 0 }
    
    init(){
        KakaoSDK.initSDK(appKey: "7942e72a93d27c86ee00caec504989f7") //native iOS app key
    }
    
    var body: some Scene {
        WindowGroup {
            // MARK: - AutoLogin X
            if userIndex == 0 { //auto login X -> Login View
                LoginView()
                    .environmentObject(scrapVM)
                    .environmentObject(userVM)
                    .onOpenURL{ url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                              _ = AuthController.handleOpenUrl(url: url)
                        }
                    }
            }
            // MARK: - AutoLogin O
            else {
                //TabView()로 변경
                TabControlView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .environmentObject(scrapVM)
                    .environmentObject(userVM)
            }
        }
    }
}
