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
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
                .disabled(isPresented) //isPresented = true일때 content 보여짐
            if isPresented {
                VStack{
                    Text(title).font(.headline).padding(.top, 20)
                    ZStack{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(scheme == .light ? Color("gray_sub") : .black_accent)
                            .opacity(0.5)
                            .frame(width: UIScreen.main.bounds.width / 1.5, height: 40, alignment: .center)
                        TextField(placeholder, text: $newCategoryTitle)
                            .disableAutocorrection(true) //자동 수정 비활성화
                            .padding(.horizontal)
                            .frame(width: UIScreen.main.bounds.width / 1.44, height: 40, alignment: .leading)
                            .padding(.leading, -10)
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 4)
                    Divider().overlay(scheme == .light ? Color("gray_bold") : Color("black_light"))
                    HStack{
                        Spacer()
                        Button(role: .cancel) {
                            withAnimation{
                                isPresented.toggle()
                            }
                        } label: {
                            Text("취소").fontWeight(.bold)
                        }
                        Spacer()
                        Divider().overlay(scheme == .light ? Color("gray_bold") : Color("black_light"))
                        Spacer()
                        Button(){
                            action(newCategoryTitle) //closure
                            withAnimation{
                                isPresented.toggle()
                            }
                        } label : {
                            Text("추가").fontWeight(.bold)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 4)
                }
                .frame(width: UIScreen.main.bounds.width / 1.35, height: UIScreen.main.bounds.height / 5)
                .background(scheme == .light ? Color("background") : Color("black_bold"))
                .cornerRadius(20)
                .overlay { RoundedRectangle(cornerRadius: 20).stroke(.quaternary, lineWidth: 1) }
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
