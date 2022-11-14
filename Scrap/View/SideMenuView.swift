//
//  SideMenuView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers
import Share

struct DragDelegate<Category: Equatable>: DropDelegate {
    @Binding var current: Category? //현재 아이템
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool { //이동시킨 후, current = nil로 변경
        current = nil
        return true
    }
}

struct Item: Identifiable, Equatable{ //category item
    let id: Int
    let title: String
    let num: Int
}

struct SideMenuView: View {
    @State private var dragging: CategoryResponse.Category?
    @Binding var categoryList : CategoryResponse.Result
    @State private var newCat = ""
    @State private var isAddingCategory = false
    @Binding var isShowingCateogry : Bool
    @State private var maxCatName = 20
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //ScrapApp에서 연결받은 EnvironmentObject
    @Binding var selected : Int
    @Binding var selectedOrder : Int
    @Environment(\.colorScheme) var scheme //Light/Dark mode

    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: -2){
                //HEADER
                HStack{
                    HStack(spacing: 16){
                        Button(action: {
                            withAnimation(.easeInOut.delay(0.3)){
                                isShowingCateogry = false
                            }
                        }){
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .frame(width: 10, height: 16)
                                .foregroundColor(scheme == .light ? .black : .gray_sub)
                        }
                        Text("카테고리")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 70, height: 20, alignment: .leading)
                            .foregroundColor(scheme == .light ? .black : .gray_sub)
                    }
                    Spacer()
                    Button(action: {
                        self.isAddingCategory.toggle() //카테고리 추가 토글
                        if !isAddingCategory { //plus icon
                            newCat = "" //초기화
                        }
                        withAnimation {
                            proxy.scrollTo(categoryList.categories.count) //scroll to last element(category)
                        }
                    }){
                        Image(systemName: isAddingCategory ? "xmark" : "plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(scheme == .light ? .black : .gray_sub)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 2))
                }
                .frame(height: 40)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 4)
                .background(scheme == .light ? .white : .black_bg)
                //Category LIST
                VStack{
                    List{
                        ForEach($categoryList.categories) { $category in
                            if category.order == 0 || category.order == 1 {
                                HStack{ //모든 자료, 분류되지 않은 자료
                                    Text(category.name)
                                        .font(.system(size: 16))
                                        .frame(width: UIScreen.main.bounds.width - 120, alignment: .leading)
                                    Text("\(category.numOfLink)")
                                        .font(.system(size: 16))
                                        .frame(width: 30, alignment: .trailing)
                                }
                                .padding(.leading, 10)
                                .listRowBackground(self.selected == category.categoryId ? (scheme == .light ? .gray_sub : .black_accent) : scheme == .light ? Color(.white) : .black_bg)
                                .onTapGesture { //클릭하면 현재 categoryID
                                    self.selected = category.categoryId
                                    self.selectedOrder = category.order
                                    if category.order == 0 {
                                        vm.getAllData(userID: userVM.userIdx) //📡 카테고리에 해당하는 자료 가져오는 통신
                                    } else {
                                        vm.getData(userID: userVM.userIdx, catID: selected, seq: "seq") //📡 카테고리에 해당하는 자료 가져오는 통신
                                    }
                                    withAnimation(.easeInOut.delay(0.3)){
                                        isShowingCateogry = false
                                    }
                                }
                            }
                        }
                        ForEach($categoryList.categories) { $category in
                            if category.order != 0 && category.order != 1 {
                                CategoryRow(category: $category, isShowingCateogry: $isShowingCateogry, selected: $selected, selectedOrder: $selectedOrder)
                                .onDrag {
                                    self.dragging = category
                                    return NSItemProvider(object: NSString())
                                }
                                .onDrop(of: [UTType.text], delegate: DragDelegate(current: $dragging))
                            }
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: {source, destination in //from source: IndexSet, to destination: Int
                            //📡 카테고리 이동 통신
                            source.forEach {
                                vm.moveCategory(from: $0, to: destination)
                                vm.movingCategory(userID: userVM.userIdx, startIdx: $0, endIdx: destination)
                            } //카테고리 이동 배열 순서 변경
                        })
                        if isAddingCategory { //카테고리 추가 버튼을 누른 경우 -> 보여짐
                            HStack{
                                TextField("새로운 카테고리", text: $newCat)
                                .padding(.leading, 12)
                                .frame(width: UIScreen.main.bounds.width - 120)
                                .disableAutocorrection(true) //자동 수정 비활성화
                                Spacer()
                                Button(action: {
                                    vm.addNewCategory(newCat: newCat, userID: userVM.userIdx) //📡 카테고리 추가 통신
                                    let newCategory = CategoryResponse.Category(categoryId: vm.categoryID, name: newCat, numOfLink: 0, order: categoryList.categories.count)
                                    vm.appendCategory(newCategory: newCategory) //post로 추가된 카테고리 이름 서버에 전송
                                    newCat = ""
                                    isAddingCategory = false
                                }) {
                                    if !newCat.isEmpty { //입력값이 있으면
                                        Image(systemName: "checkmark") //한 글자라도 있어야 버튼 활성화
                                            .foregroundColor(.gray_bold)
                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width - 67)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.trailing, 10)
                    .listStyle(PlainListStyle())
                }
            }
            .background(scheme == .light ? .white : .black_bg)
        }
        .onAppear {
            print("🚨🚨SideMenuView 나타남🚨🚨")
        }
    }

    private func delete(indexSet: IndexSet) {
        for index in indexSet {
            vm.removeCategory(index: index)
            vm.deleteCategory(categoryID: index) //📡 카테고리 삭제 통신
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 0),
           CategoryResponse.Category(categoryId: 1, name: "2", numOfLink: 1, order: 2),
                                                                                  CategoryResponse.Category(categoryId: 2, name: "3", numOfLink: 1, order: 3)])), isShowingCateogry: .constant(true), selected: .constant(0), selectedOrder: .constant(0))
            .environmentObject(ScrapViewModel())
            .preferredColorScheme(.dark)
//        MainHomeView(popRootView: .constant(true))
//            .environmentObject(ScrapViewModel())
//            .environmentObject(UserViewModel())
    }
}
