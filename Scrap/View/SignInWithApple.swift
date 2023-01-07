//
//  SignInWithApple.swift
//  Scrap
//
//  Created by 김영선 on 2023/01/03.
//

import SwiftUI
import AuthenticationServices

struct SignInWithApple: UIViewRepresentable {
    @Environment(\.colorScheme) var scheme
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        return ASAuthorizationAppleIDButton(type: .default, style: scheme == .light ? .black : .white)
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
