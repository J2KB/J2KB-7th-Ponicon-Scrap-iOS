//
//  AddCategoryAlert.swift
//  Scrap
//
//  Created by 김영선 on 2022/11/23.
//

import Foundation
import SwiftUI

struct AddCategoryAlert: ViewModifier {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @Binding var isPresented: Bool //alert창을 열었나?
    @Binding var newCategoryTitle : String //사용자가 추가한 새로운 카테고리 타이틀
    let placeholder : String = "카테고리를 입력해주세요"
    let title : String = "새로운 카테고리"
    let action: (String) -> Void
    private let screenWidth = UIScreen.main.bounds.width
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
                .disabled(isPresented) //isPresented = true일때 content 보여짐
            if isPresented {
                VStack(spacing: 0){
                    ZStack{
                        //Text, TextField
                        Rectangle()
                            .fill(scheme == .light ? Color(.systemGray6) :.black_bold)
                            .frame(width: screenWidth / 1.4, height: screenWidth / 3.6, alignment: .center)
                            .cornerRadius(14, corners: .topLeft)
                            .cornerRadius(14, corners: .topRight)
                        VStack(spacing: 12){
                            Text(/*title*/"New Category")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.top, 6)
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(scheme == .light ? Color(.systemGray6) :.black_bold)
                                    .shadow(radius: 1)
                                    .frame(width: screenWidth / 1.7, height: screenWidth / 13, alignment: .center)
                                TextField("새로운 카테고리 이름", text: $newCategoryTitle)
                                    .font(.system(size: 13))
                                    .disableAutocorrection(true) //자동 수정 비활성화
                                    .padding(.horizontal)
                                    .frame(width: screenWidth / 1.62, height: screenWidth / 10, alignment: .leading)
                                    .padding(.leading, -10)
                            }
                        }
                    }
                    Divider()
                        .overlay(scheme == .light ? Color(.systemGray5) : Color(.systemGray))
                        .frame(width: screenWidth / 1.4)
                    ZStack{
                        //Buttons
                        Rectangle()
                            .fill(scheme == .light ? Color(.systemGray6) :.black_bold)
                            .frame(width: screenWidth / 1.4, height: screenWidth / 8, alignment: .center)
                            .cornerRadius(14, corners: .bottomLeft)
                            .cornerRadius(14, corners: .bottomRight)
                        HStack(spacing: 0){
                            Button(role: .cancel) {
                                withAnimation {
                                    isPresented = false
                                }
                            } label: {
                                Text("취소")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .frame(width: screenWidth / 2.8, height: screenWidth / 8)
                            Divider()
                                .overlay(scheme == .light ? Color(.systemGray5) : Color(.systemGray))
                                .frame(height: screenWidth / 8)
                            Button() {
                                action(newCategoryTitle)
                                withAnimation {
                                    isPresented = false
                                }
                            } label : {
                                Text("추가")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .frame(width: screenWidth / 2.8, height: screenWidth / 8)
                        }
                    }
                }
            }
        }
    }
}

extension View {
    public func addCategoryAlert(
        isPresented: Binding<Bool>,
        newCategoryTitle : Binding<String>,
        placeholder : String,
        title: String,
        action: @escaping (String) -> Void
    ) -> some View {
        self.modifier(AddCategoryAlert(isPresented: isPresented, newCategoryTitle: newCategoryTitle, action: action))
    }
}
