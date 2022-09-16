//
//  SideMenuView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import Combine

struct SideMenuView: View {
    @State private var arr = ["category 1", "category 2", "category 3", "category 4"]
    @State private var allDoc = "모든 자료"
    @State private var notDi = "분류되지 않은 자료"
    @State private var newCat = "" //초기화해줘야 함
    @Binding var isAddingCategory : Bool
    @State private var maxCatName = 20
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    CategoryRowView(text: $allDoc) //모든 자료
                        .padding(.vertical, 2)
                    CategoryRowView(text: $notDi)  //분류되지 않은 자료
                        .padding(.vertical, 2)
                    ForEach($arr, id: \.self) { i in
                        CategoryRowView(text: i) //button으로 변경하기
                            .padding(.vertical, 2)
                    }
                    if isAddingCategory {
                        VStack(spacing: 2){
                            TextField("새로운 카테고리를 입력해주세요.", text: $newCat)
                                .disableAutocorrection(true) //자동 수정 비활성화
                                .padding(.horizontal)
                                .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height / 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray)
                                        .frame(width: UIScreen.main.bounds.width/1.21, height: UIScreen.main.bounds.height / 14)
                                )
                                .onReceive(Just(newCat), perform: { _ in
                                    if maxCatName < newCat.count {
                                        newCat = String(newCat.prefix(maxCatName))
                                    }
                                })
//                            if newCat.count <= 1, !isAddingCategory {
                                Text("*최소 1글자 이상 입력해주세요") //관련 에러 메세지 따로 출력되도록
                                    .font(.caption)
                                    .foregroundColor(Color.red)
                                    .frame(width: UIScreen.main.bounds.width/1.28, alignment: .topLeading)
//                            }
                        }
                    }
                }
//            List { //is enable to scrolling
//                ForEach(0...5, id: \.self) { id in
//                    if id == 2 {
//                        SideOptionView()
//                    }else {
//                        SideOptionView()
//                    }
//
//                }
            }
//            .listStyle(GroupedListStyle())
//            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            HomeView()
            SideMenuView(isAddingCategory: .constant(true))
        }
    }
}
