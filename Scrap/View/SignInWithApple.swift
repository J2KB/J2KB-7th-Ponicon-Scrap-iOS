//
//  SignInWithApple.swift
//  Scrap
//
//  Created by 김영선 on 2023/01/03.
//

import SwiftUI
import AuthenticationServices

struct SignInWithApple: UIViewRepresentable {
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        return ASAuthorizationAppleIDButton()
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
