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
        VStack{
            if isEditingName { //이름 수정시, textfield로 변경
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(scheme == .light ? Color("gray_sub") : Color("black_bold"))
                        .opacity(0.4)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 32, alignment: .leading)
                    TextField("카테고리 이름", text: $categoryName)
                        .frame(width: UIScreen.main.bounds.width - 50, alignment: .leading)
                        .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                        .onSubmit{ //return 시 -> 서버 통신
                            //modify category name in local category list
                            vm.renameCategory(id: category.categoryId, renamed: categoryName)
                            //📡 카테고리 이름 수정 서버 통신
                            vm.modifyCategory(categoryID: category.categoryId, categoryName: categoryName)
                            self.isEditingName.toggle()
                        }
                }
            } else { //아니면 그냥 text로 나타냄
                Text(categoryName)
                    .frame(width: UIScreen.main.bounds.width - 50, height: 32, alignment: .leading)
                    .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
            }
            List {
                Section {
                    Button(action: {
                        if !isEditingName { //이름 수정하지 않을 때만 활성화
                            print("renamed category title")
                            self.isEditingName.toggle()
                            print(isEditingName)
                        }
                    }){
                        Label("이름 수정", systemImage: "pencil")
                            .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                    }
                    Button(action: {
                        if !isEditingName { //이름 수정하지 않을 때만 활성화
                            self.isDelete = true
                        }
                    }){
                        Label("삭제", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
            }
            .background(scheme == .light ? Color("background") : .black_bg)
        }
        .padding(.top, 48)
        .background(scheme == .light ? Color("background") : .black_bg)
        .onAppear {
            self.categoryName = category.name
        }
        .alert("정말 삭제하시겠습니까?", isPresented: $isDelete, actions: {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                //📡 카테고리 삭제 서버 통신
                vm.deleteCategory(categoryID: category.categoryId) //📡 카테고리 삭제 통신
                vm.removeCategory(index: category.order) //선택한 카테고리의 인덱스
                self.isPresentHalfModal = false
                self.isDelete = false
                print("delete category")
            }
        }/*, message: {
            Text("삭제한 카테고리는 복구할 수 없습니다")
        }*/)
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
