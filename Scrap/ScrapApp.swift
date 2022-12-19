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
    var userIndex : Int { return UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") ?? 0 }
    
    init(){
        KakaoSDK.initSDK(appKey: "7942e72a93d27c86ee00caec504989f7") //native iOS app key
    }
    
    var body: some Scene {
        WindowGroup {
            // MARK: - AutoLogin X
            if userIndex == 0 { //auto login X -> Login View
                LoginView()
                    .onAppear(perform: UIApplication.shared.addTargetGestureRecognizer)
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
                MainHomeView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .environmentObject(scrapVM)
                    .environmentObject(userVM)
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
