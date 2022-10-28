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
    @StateObject var network = Network()
    @State private var autoLogin = false
//    let userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID")
    
    init(){
        KakaoSDK.initSDK(appKey: "7942e72a93d27c86ee00caec504989f7") //native app key
    }
    
    var body: some Scene {
        WindowGroup {
            if !network.connected {
//                if userIdx == 0 { //auto login X -> Login View
                    LoginView(/*autoLogin: .constant(false)*/)
                        .environmentObject(scrapVM)
                        .environmentObject(userVM)
                        .onOpenURL{ url in
                            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                  _ = AuthController.handleOpenUrl(url: url)
                            }
                        }
//                } else { //auto login o -> Main Home View
//                    LoginView(/*autoLogin: .constant(true)*/)
//                        .environmentObject(scrapVM)
//                        .environmentObject(userVM)
//                }
            } else {
                OfflineView()
            }
        }
    }
}
