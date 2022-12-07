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
    @Environment(\.colorScheme) var scheme //Light/Dark mode
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
    
    var body: some View {
        ZStack{
            VStack(spacing: -2){
                //HEADER
                HStack{
                    HStack(spacing: 16){
                        Button(action: {
                            if !isAddingCategory {
                                withAnimation(.spring()){
                                    isShowingCateogry = false
                                }
                            }
                        }){
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .frame(width: 10, height: 16)
                                .foregroundColor(Color("basic_text"))
                        }
                        Text("카테고리")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 70, height: 20, alignment: .leading)
                            .foregroundColor(Color("basic_text"))
                    }
                    Spacer()
                    Button(action: {
                        self.isAddingCategory = true //카테고리 추가 -> 추가 버튼 누름
                    }){
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color("basic_text"))
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 2))
                }//Header HStack
                .frame(height: 40)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 4)
                .background(Color("background"))
                //Category LIST
                VStack{
                    List{
                        ForEach($categoryList.categories) { $category in
                            if category.order == 0 || category.order == 1 {
                                ZStack {
                                    HStack{ //모든 자료, 분류되지 않은 자료
                                        Text(category.name)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("basic_text"))
                                            .frame(width: UIScreen.main.bounds.width - 120, alignment: .leading)
                                        Text("\(category.numOfLink)")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("basic_text"))
                                            .frame(width: 30, alignment: .trailing)
                                    }
                                    Button(action: {
                                        if !isAddingCategory {
//                                            vm.isLoading = .loading
                                            withAnimation(.spring()){
                                                isShowingCateogry = false
                                            }
                                            self.selected = category.categoryId
                                            self.selectedOrder = category.order
                                            if category.order == 0 { vm.inquiryAllData(userID: userVM.userIdx) } //📡 카테고리에 해당하는 자료 가져오는 통신
                                            else { vm.inquiryData(userID: userVM.userIdx, catID: selected) } //📡 카테고리에 해당하는 자료 가져오는 통신
                                        }
                                    }) {
                                        Rectangle()
                                            .frame(width: UIScreen.main.bounds.width - 60)
                                            .opacity(0)
                                    }
                                }
                                .listRowBackground(self.selected == category.categoryId ? Color("selected_color") : Color("background"))
                            }
                        }
                        ForEach($categoryList.categories) { $category in
                            if category.order != 0 && category.order != 1 {
                                CategoryRow(category: $category, isShowingCateogry: $isShowingCateogry, selected: $selected, isAddingCategory: $isAddingCategory, selectedOrder: $selectedOrder)
                                    .id(category.id)
                                .onDrag {
                                    self.dragging = category
                                    return NSItemProvider(object: NSString())
                                }
                                .onDrop(of: [UTType.text], delegate: DragDelegate(current: $dragging))
                            }
                        }
                        .onMove(perform: {source, destination in //from source: IndexSet, to destination: Int
                            source.forEach {
                                print($0)
                                print(destination)
                                vm.moveCategoryRowInList(from: $0, to: destination)
                                vm.movingCategory(userID: userVM.userIdx, startIdx: $0, endIdx: destination) //📡 카테고리 이동 통신
                            }
                        })
                    }
                }//CategoryList VStack
                .refreshable {
                    vm.inquiryCategoryData(userID: userVM.userIdx)
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.trailing, 10)
                .listStyle(PlainListStyle())
            }//VStack
            .background(Color("background"))
            if isAddingCategory { //카테고리 추가 alert창 켜지면 뒷 배경 블러 처리
                Color("blur_background").ignoresSafeArea()
            }
        }//ZStack
        .background(Color("background"))
        .addCategoryAlert(isPresented: $isAddingCategory, newCategoryTitle: $newCat, placeholder: "새로운 카테고리 이름을 입력해주세요", title: "카테고리 추가하기", action: { _ in
            vm.addNewCategory(newCat: newCat, userID: userVM.userIdx) //📡 카테고리 추가 통신
            let newCategory = CategoryResponse.Category(categoryId: vm.categoryID, name: newCat, numOfLink: 0, order: categoryList.categories.count)
            vm.appendNewCategoryToCategoryList(new: newCategory) //post로 추가된 카테고리 이름 서버에 전송
            newCat = ""
        })
    }//body
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 0),
           CategoryResponse.Category(categoryId: 1, name: "2", numOfLink: 1, order: 2), CategoryResponse.Category(categoryId: 2, name: "3", numOfLink: 1, order: 3)])), isShowingCateogry: .constant(true), selected: .constant(0), selectedOrder: .constant(0))
            .environmentObject(ScrapViewModel())
            .preferredColorScheme(.dark)
    }
}
