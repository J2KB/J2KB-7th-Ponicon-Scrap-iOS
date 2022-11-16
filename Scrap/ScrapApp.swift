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
    var userIdx : Int { return UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") ?? 0 }
    @State private var isWebUrl = true
    var webUrl : String {
        return UserDefaults(suiteName: "group.com.thk.Scrap")?.string(forKey: "WebURL") ?? ""
    }
    
    init(){
        KakaoSDK.initSDK(appKey: "7942e72a93d27c86ee00caec504989f7") //native app key
    }
    
    var body: some Scene {
        WindowGroup {
            if !network.connected {
                //자료 저장인지 확인하기....
                //ViewController에서 자료 저장인지 알아와야됨... 넘길 수 있는지 확인하기
                if userIdx == 0 { //auto login X -> Login View
                    LoginView()
                        .onAppear(perform: UIApplication.shared.addTargetGestureRecognizer)
                        .environmentObject(scrapVM)
                        .environmentObject(userVM)
                        .onOpenURL{ url in
                            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                  _ = AuthController.handleOpenUrl(url: url)
                            }
                        }
                } else { //auto login o -> Main Home View
                    if webUrl != "" {
                        MainHomeView()
                            .sheet(isPresented: $isWebUrl) {
                                SaveDataView(categoryList: $scrapVM.categoryList.result)
                            }
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                            .environmentObject(scrapVM)
                            .environmentObject(userVM)
                    }else {
                        MainHomeView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                            .environmentObject(scrapVM)
                            .environmentObject(userVM)
                    }
                }
            } else {
                OfflineView()
            }
        }
    }
}

extension UIApplication {
    func addTargetGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication : UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
