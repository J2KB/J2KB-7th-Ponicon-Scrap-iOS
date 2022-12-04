//
//  CategorySheetView.swift
//  Scrap
//
//  Created by 김영선 on 2022/11/21.
//

import SwiftUI

struct CategorySheetView: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @Binding var category : CategoryResponse.Category
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @State private var isEditingName = false
    @Binding var isPresentHalfModal : Bool
    @State private var isDelete = false
    @State private var categoryName = ""
    
    var body: some View {
        VStack(spacing: 20){
            if isEditingName { //이름 수정시, textfield로 변경
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("textfield_color"))
                        .opacity(0.4)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 40, alignment: .leading)
                    TextField("카테고리 이름", text: $categoryName)
                        .font(.system(size: 22, weight: .regular))
                        .frame(width: UIScreen.main.bounds.width - 60, alignment: .leading)
                        .foregroundColor(Color("basic_text"))
                        .onSubmit{ //return 시 -> 서버 통신
                            //modify category name in local category list
                            vm.renameCategory(id: category.categoryId, renamed: categoryName)
                            //📡 카테고리 이름 수정 서버 통신
                            vm.modifyCategory(categoryID: category.categoryId, categoryName: categoryName)
                            self.isEditingName.toggle()
                        }
                }
                .padding(.bottom, 10)
            } else { //아니면 그냥 text로 나타냄
                Text(categoryName)
                    .font(.system(size: 22, weight: .regular))
                    .frame(width: UIScreen.main.bounds.width - 60, height: 40, alignment: .leading)
                    .foregroundColor(Color("basic_text"))
                    .padding(.bottom, 10)
            }
            Button(action: {
                self.isEditingName.toggle()
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("list_color"))
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                    Label(isEditingName ? "수정 완료" : "이름 수정", systemImage: isEditingName ? "checkmark" : "pencil")
                        .foregroundColor(Color("basic_text"))
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                        .padding(.leading, 40)
                }
            }
            Button(action: {
                if !isEditingName { //이름 수정하지 않을 때만 활성화
                    self.isDelete = true
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
            self.categoryName = category.name
        }
        .alert("정말 삭제하시겠습니까?", isPresented: $isDelete, actions: {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                //📡 카테고리 삭제 서버 통신
                vm.deleteCategory(categoryID: category.categoryId) //📡 카테고리 삭제 통신
                vm.removeCategoryFromCategoryList(categoryID: category.categoryId) //선택한 카테고리의 인덱스
                self.isPresentHalfModal = false
                self.isDelete = false
            }
        })
    }
}

struct CategorySheetView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySheetView(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), isPresentHalfModal: .constant(false))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
