//
//  CategoryRow.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/23.
//

import SwiftUI

struct CategoryRow: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    @State private var categoryName = "category"
    @State private var isPresentCategoryModalSheet = false
    
    @Binding var category : CategoryResponse.Category
    @Binding var isShowingCategorySideMenuView : Bool
    @Binding var selectedCategoryId : Int
    @Binding var isAddingNewCategory : Bool
    @Binding var selectedCategoryOrder : Int
    
    var title: String {
        var cnt = 0
        var tmp = category.name
        while cnt <= Int(UIScreen.main.bounds.width - 120) {
            tmp += " "
            cnt += 1
        }
        return tmp
    }
    
    var body: some View {
        HStack{
            HStack{
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color("basic_text"))
                    .frame(width: UIScreen.main.bounds.width - 120, alignment: .leading)
                Text("\(category.numOfLink)")
                    .font(.system(size: 16))
                    .foregroundColor(Color("basic_text"))
                    .frame(width: 30, alignment: .trailing)
            }
            .onTapGesture {
                if !isAddingNewCategory {
                    withAnimation(.spring()){
                        isShowingCategorySideMenuView = false
                    }
                    self.selectedCategoryId = category.categoryId
                    self.selectedCategoryOrder = category.order
                    scrapVM.getDataByCategory(userID: userVM.userIndex, categoryID: selectedCategoryId)
                }
            }
            //modal shet 등장
            Button(action:{
                if !isAddingNewCategory && !isPresentCategoryModalSheet {
                    self.isPresentCategoryModalSheet = true //half-modal view 등장
                    self.selectedCategoryId = category.categoryId
                }
            }){
                ZStack{
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color("option_button"))
                }
                .frame(width: 30, height: 24)
            }
        }
        .padding(.leading, 10)
        .listRowBackground(self.selectedCategoryId == category.categoryId ? Color("selected_color"): .none)
        .sheet(isPresented: $isPresentCategoryModalSheet){
            HalfSheet {
                CategorySheetView(category: $category, isPresentCategoryModalSheet: $isPresentCategoryModalSheet)
            }
            .ignoresSafeArea()
        }
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), isShowingCategorySideMenuView: .constant(true), selectedCategoryId: .constant(0), isAddingNewCategory: .constant(true), selectedCategoryOrder: .constant(0))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
