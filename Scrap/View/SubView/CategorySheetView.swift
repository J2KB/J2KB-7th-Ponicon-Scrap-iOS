//
//  CategorySheetView.swift
//  Scrap
//
//  Created by 김영선 on 2022/11/21.
//

import SwiftUI

struct CategorySheetView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var scrapVM : ScrapViewModel
    
    @State private var isEditingCategoryName = false
    @State private var isDeleteCategory = false
    @State private var renamedCategoryName = ""
    
    @Binding var category : CategoryResponse.Category
    @Binding var isPresentCategoryModalSheet : Bool
    
    var body: some View {
        VStack(spacing: 20){
            if isEditingCategoryName { //이름 수정시, textfield로 변경
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("textfield_color"))
                        .opacity(0.4)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 40, alignment: .leading)
                    HStack {
                        TextField("카테고리 이름", text: $renamedCategoryName)
                            .font(.system(size: 18, weight: .regular))
                            .frame(width: UIScreen.main.bounds.width - 100, alignment: .leading)
                            .foregroundColor(Color("basic_text"))
                        Button(action: {
                            scrapVM.renameCategory(categoryID: category.categoryId, renamed: renamedCategoryName)
                            scrapVM.modifyCategoryName(categoryID: category.categoryId, categoryName: renamedCategoryName)
                            self.isEditingCategoryName = false
                        }) {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(scheme == .light ? .black : .white)
                        }
                    }
                }
                .padding(.bottom, 10)
            } else { //아니면 그냥 text로 나타냄
                Text(renamedCategoryName)
                    .font(.system(size: 18, weight: .regular))
                    .frame(width: UIScreen.main.bounds.width - 60, height: 40, alignment: .leading)
                    .foregroundColor(Color("basic_text"))
                    .padding(.bottom, 10)
            }
            Button(action: {
                self.isEditingCategoryName = true
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("list_color"))
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                    Label("이름 수정", systemImage: "pencil")
                        .foregroundColor(Color("basic_text"))
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                        .padding(.leading, 40)
                }
            }
            Button(action: {
                if !isEditingCategoryName { //이름 수정하지 않을 때만 활성화
                    self.isDeleteCategory = true
                }
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("list_color"))
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                    Label("삭제", systemImage: "trash")
                        .foregroundColor(.red)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                        .padding(.leading, 40)
                }
            }
            Spacer()
        }
        .padding(.top, 48)
        .background(Color("sheet_background"))
        .onAppear {
            self.renamedCategoryName = category.name
        }
        .alert("정말 삭제하시겠습니까?", isPresented: $isDeleteCategory, actions: {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                scrapVM.deleteCategory(categoryID: category.categoryId) //📡 카테고리 삭제 통신
                scrapVM.removeCategoryFromCategoryList(categoryID: category.categoryId) //선택한 카테고리의 인덱스
                self.isPresentCategoryModalSheet = false
                self.isDeleteCategory = false
            }
        })
    }
}

struct CategorySheetView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySheetView(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), isPresentCategoryModalSheet: .constant(false))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
