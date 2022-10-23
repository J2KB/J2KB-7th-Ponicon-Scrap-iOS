//
//  CategoryRow.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/23.
//

import SwiftUI

struct CategoryRow: View {
    @Binding var category : CategoryResponse.Category
    @State private var isEditing = false
    @State private var categoryName = "category"
    @Binding var selected : Int
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요

    var body: some View {
//        VStack{
        if !isEditing { //edit mode가 아닐 때
            HStack{
                HStack{
                    Button(action:{
                        self.selected = category.categoryId
                        print("\(selected) is selected category id")
                        vm.getData(userID: 16, catID: selected, seq: "seq")
                        print("get data")
                    }){
                        Text(category.name)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 1.87), alignment: .leading)
                    }
                    Text("\(category.numOfLink)")
                        .font(.system(size: 16))
                        .frame(width: 30, alignment: .trailing)
                    .foregroundColor(.black)
                }
                
                Button(action:{
                    self.isEditing.toggle() //edit mode로 변경
                    print("enter edit mode")
                }){
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.gray_bold)
                }
            }
            .padding(.leading, 10)
            .listRowBackground(self.selected == category.categoryId ? .gray_sub : Color(.white))
        } else {
            HStack{
                TextField(category.name, text: $category.name)
                    .font(.system(size: 16))
                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.3), alignment: .leading)
                Button(action:{
                    self.isEditing.toggle() //edit mode 종료
                    //📡 카테고리 이름 수정 서버 통신
                    //modify category name in local category list
                    print("exit edit mode")
                }){
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.gray_bold)
                }
            }
            .padding(.leading, 10)
            .listRowBackground(self.selected == category.categoryId ? .gray_sub : Color(.white))
        }
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), selected: .constant(0))
    }
}
