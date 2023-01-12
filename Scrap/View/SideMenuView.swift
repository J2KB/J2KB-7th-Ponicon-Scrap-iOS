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
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var dragging: CategoryResponse.Category?
    @State private var newCategoryName = ""
    @State private var isAddingCategory = false
    
    @Binding var categoryList : CategoryResponse.Result
    @Binding var isShowingCategoryView : Bool
    @Binding var selectedCategoryId : Int
    @Binding var selectedCategoryOrder : Int
    
    var body: some View {
        ZStack{
            VStack(spacing: -2){
                //HEADER
                HStack{
                    HStack(spacing: 4){
                        Button(action: {
                            if !isAddingCategory {
                                withAnimation(.spring()){
                                    isShowingCategoryView = false
                                }
                            }
                        }){
                            ZStack {
                                Image(systemName: "chevron.backward")
                                    .resizable()
                                    .frame(width: 10, height: 16)
                                    .foregroundColor(Color("basic_text"))
                            }
                            .frame(width: 28, height: 28)
                        }
                        Text("카테고리")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 70, height: 20, alignment: .leading)
                            .foregroundColor(Color("basic_text"))
                    }
                    Spacer()
                    Button(action: { //새로운 카테고리 추가 버튼
                        self.isAddingCategory = true
                    }){
                        ZStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(Color("basic_text"))
                        }
                        .frame(width: 28, height: 28)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 2))
                }//Header HStack
                .frame(height: 40)
                .padding(EdgeInsets(top: 0, leading: 6, bottom: 10, trailing: 10))
                .background(scheme == .light ? .white : .black)
                //Category LIST
                VStack{
                    List{
                        ForEach($categoryList.categories) { $category in
                            if category.order == 0 || category.order == 1 {
                                ZStack {
                                    HStack(spacing: 20){ //모든 자료, 분류되지 않은 자료
                                        Text(category.name)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("basic_text"))
                                            .frame(width: UIScreen.main.bounds.width / 1.39, alignment: .leading)
                                        Text("\(category.numOfLink)")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("basic_text"))
                                            .frame(width: UIScreen.main.bounds.width / 14, alignment: .trailing)
                                    }
                                    
                                    Button(action: {
                                        if !isAddingCategory {
                                            withAnimation(.spring()){
                                                isShowingCategoryView = false
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //0.5초 뒤에 자료 조회 -> SideMenuView 사라진 뒤 진행하도록
                                                self.selectedCategoryId = category.categoryId
                                                self.selectedCategoryOrder = category.order
                                            }
                                        }
                                    }) {
                                        Rectangle()
                                            .frame(width: UIScreen.main.bounds.width - 70)
                                            .opacity(0)
                                    }
                                }
                                .listRowBackground(self.selectedCategoryId == category.categoryId ? Color("selected_color") : .none)
                            }
                        }
                        ForEach($categoryList.categories) { $category in
                            if category.order != 0 && category.order != 1 {
                                CategoryRow(category: $category, isShowingCategorySideMenuView: $isShowingCategoryView, selectedCategoryId: $selectedCategoryId, isAddingNewCategory: $isAddingCategory, selectedCategoryOrder: $selectedCategoryOrder)
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
                                scrapVM.moveCategoryRowInList(from: $0, to: destination)
                                scrapVM.movingCategory(userID: userVM.userIndex, startIdx: $0, endIdx: destination) //📡 카테고리 이동 통신
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    scrapVM.getCategoryListData(userID: userVM.userIndex)
                                }
                            }
                        })
                    }//List
                }//CategoryList VStack
                .refreshable {
                    scrapVM.getCategoryListData(userID: userVM.userIndex)
                }
                .listStyle(PlainListStyle())
            }//VStack
            if isAddingCategory { //카테고리 추가 alert창 켜지면 뒷 배경 블러 처리
                Color("blur_background").ignoresSafeArea()
            }
        }//ZStack
        .background(scheme == .light ? .white : .black)
        .addCategoryAlert(isPresented: $isAddingCategory, newCategoryTitle: $newCategoryName, placeholder: "새로운 카테고리 이름을 입력해주세요", title: "카테고리 추가하기", action: { _ in
            scrapVM.addNewCategory(newCat: newCategoryName, userID: userVM.userIndex) //📡 카테고리 추가 통신
            newCategoryName = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                scrapVM.getCategoryListData(userID: userVM.userIndex)
            }
        })
    }//body
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "분류되지 않은 자료", numOfLink: 1, order: 0),
           CategoryResponse.Category(categoryId: 1, name: "2", numOfLink: 1, order: 2), CategoryResponse.Category(categoryId: 2, name: "3", numOfLink: 1, order: 3)])), isShowingCategoryView: .constant(true), selectedCategoryId: .constant(0), selectedCategoryOrder: .constant(0))
            .environmentObject(ScrapViewModel())
    }
}
