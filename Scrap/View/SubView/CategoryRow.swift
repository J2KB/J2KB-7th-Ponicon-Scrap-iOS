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
    var body: some View {
        HStack{
            if !isEditing {
                Text(category.name)
                    .font(.system(size: 16))
                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 1.8), alignment: .leading)
                HStack(spacing: 4){
                    Text("\(category.numOfLink)")
                        .font(.system(size: 16))
                        .frame(width: 30, alignment: .trailing)
                    Button(action:{
                        self.isEditing = true
                    }){
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.gray_bold)
                    }
                    .padding(4)
                }
            } else {
                HStack(spacing: 4){
                    TextField(category.name, text: $category.name)
                        .font(.system(size: 16))
                        .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.2), alignment: .leading)
                    Button(action:{
                        self.isEditing = false
                        //📡 카테고리 이름 수정 서버 통신
                    }){
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.gray_bold)
                    }
                    .padding(4)
                }
            }
        }
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)))
    }
}
