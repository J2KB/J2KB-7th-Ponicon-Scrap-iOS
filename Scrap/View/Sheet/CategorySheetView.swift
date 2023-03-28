//
//  CategorySheetView.swift
//  Scrap
//
//  Created by 김영선 on 2022/11/21.
//

import SwiftUI

enum nameField {
    case rename
}

struct CategorySheetView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var scrapVM : ScrapViewModel
    @FocusState var focusState : nameField?
    
    @State private var isEditingCategoryName = false
    @State private var isDeleteCategory = false
    @State private var renamedCategoryName = ""
    
    @Binding var category : CategoryResponse.Category
    @Binding var isPresentCategoryBottomSheet : Bool
    
    var body: some View {
        VStack(spacing: 20){
            if isEditingCategoryName {
                HStack{
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("textfield_color"))
                            .opacity(0.4)
                            .frame(width: UIScreen.main.bounds.width / 1.25, height: 36, alignment: .leading)
                        HStack(spacing: 13){
                            TextField("카테고리 이름", text: $renamedCategoryName)
                                .focused($focusState, equals: .rename)
                                .font(.system(size: 14, weight: .regular))
                                .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                                .foregroundColor(Color("basic_text"))
                            Button(action: {
                                renamedCategoryName = "" //clear category name
                            }) {
                                ZStack{
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 14, height: 14)
                                }
                                .frame(width: 24, height: 36)
                            }
                        }
                    }
                    Button(action: {
                        if !renamedCategoryName.isEmpty {
                            scrapVM.renameCategory(categoryID: category.categoryId, renamed: renamedCategoryName)
                            scrapVM.modifyCategoryName(categoryID: category.categoryId, categoryName: renamedCategoryName)
                            isEditingCategoryName = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                scrapVM.getCategoryListData(userID: userVM.userIndex)
                            }
                        } else {
                            renamedCategoryName = category.name //원래 카테고리 이름으로
                            isEditingCategoryName = false
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("list_color"))
                                .frame(width: 36, height: 36, alignment: .leading)
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(Color("blue_bold"))
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
                isEditingCategoryName = true
                focusState = .rename
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
                    isDeleteCategory = true
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
            renamedCategoryName = category.name
        }
        .alert("정말 삭제하시겠습니까?", isPresented: $isDeleteCategory, actions: {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                scrapVM.deleteCategory(categoryID: category.categoryId) //📡 카테고리 삭제 통신
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scrapVM.getCategoryListData(userID: userVM.userIndex)
                }
                isPresentCategoryBottomSheet = false
                isDeleteCategory = false
            }
        })
    }
}

struct CategorySheetView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySheetView(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), isPresentCategoryBottomSheet: .constant(false))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
