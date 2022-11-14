////
////  RootView.swift
////  Scrap
////
////  Created by 김영선 on 2022/11/14.
////
//
//import SwiftUI
//import KakaoSDKAuth
//import KakaoSDKCommon
//
//struct RootView: View {
//    @StateObject var scrapVM = ScrapViewModel()
//    @StateObject var userVM = UserViewModel()
////    @State private var autoLogin = false
//    let userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID")
//
//    init(){
//        KakaoSDK.initSDK(appKey: "7942e72a93d27c86ee00caec504989f7") //native app key
//    }
//
//    var body: some View {
//        if userIdx == 0 { //auto login X -> Login View
//            LoginView()
//                .environmentObject(scrapVM)
//                .environmentObject(userVM)
//                .onOpenURL{ url in
//                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
//                          _ = AuthController.handleOpenUrl(url: url)
//                    }
//                }
//        } else { //auto login o -> Main Home View
//            MainHomeView()
//                .navigationBarBackButtonHidden(true)
//                .navigationBarHidden(true)
//                .environmentObject(scrapVM)
//                .environmentObject(userVM)
//        }
//    }
//}
//
//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootView()
//    }
//}
