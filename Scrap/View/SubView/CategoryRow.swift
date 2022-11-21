//
//  CategoryRow.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/23.
//

import SwiftUI


struct CategoryRow: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel
    @Binding var category : CategoryResponse.Category
    @State private var categoryName = "category"
    @Binding var isShowingCateogry : Bool
    @Binding var selected : Int
    @State private var isChangeRow = true
    @State private var isPresentHalfModal = false
    @Binding var isAddingCategory : Bool
    @Binding var selectedOrder : Int
    
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
                    .frame(width: UIScreen.main.bounds.width - 120, alignment: .leading)
                Text("\(category.numOfLink)")
                    .font(.system(size: 16))
                    .frame(width: 30, alignment: .trailing)
            }
            .onTapGesture {
                if !isAddingCategory {
                    vm.isLoading = .loading
                    withAnimation(.spring()){
                        isShowingCateogry = false
                    }
                    self.selected = category.categoryId
                    self.selectedOrder = category.order
                    self.isChangeRow = true
//                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(selected, forKey: "lastCategory") //마지막 카테고리 id 저장
                    print("\(selected) is selected category id")
                    vm.getData(userID: userVM.userIdx, catID: selected, seq: "seq")
                }
            }
            //modal shet 등장
            Button(action:{
                if !isAddingCategory && !isPresentHalfModal {
                    self.isPresentHalfModal = true //half-modal view 등장
                    self.selected = category.categoryId
                }
            }){
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray_bold)
            }
            .frame(width: 24, height: 32)
        }
        .padding(.leading, 10)
        .listRowBackground(self.selected == category.categoryId ? (scheme == .light ? .gray_sub : .black_accent) : scheme == .light ? Color(.white) : .black_bg)
        .sheet(isPresented: $isPresentHalfModal){
            HalfSheet {
                CategorySheetView(category: $category, isPresentHalfModal: $isPresentHalfModal)
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
        CategoryRow(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), isShowingCateogry: .constant(true), selected: .constant(0), isAddingCategory: .constant(true), selectedOrder: .constant(0))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
