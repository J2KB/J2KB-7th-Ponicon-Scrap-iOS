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

struct CategoryView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
        
    @State private var dragging: CategoryResponse.Category?
    @State private var newCategoryName = ""
    @State private var isAddingCategory = false
    @State private var isPresentCategoryBottomSheet = false //카테고리 바텀시트 onoff
    @State private var detailCategory = CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)
    
    @Binding var categoryList : CategoryResponse.Result
    @Binding var isShowingCategorySideMenuView : Bool        //카테고리 뷰 onoff
    @Binding var selectedCategoryId : Int
    @Binding var selectedCategoryOrder : Int
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                //HEADER
                HStack{
                    HStack(spacing: 4){
                        Button(action: {
                            withAnimation(.spring()){
                                if !self.isPresentCategoryBottomSheet {
                                    self.isShowingCategorySideMenuView = false //main home view로 돌아가기
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
                        .padding(.leading, 6)
                        Text("카테고리")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 70, height: 28, alignment: .leading)
                            .foregroundColor(Color("basic_text"))
                    }
                    Spacer()
                    Button(action: { //새로운 카테고리 추가 버튼
                        if !self.isPresentCategoryBottomSheet {
                            self.isAddingCategory = true
                        }
                    }){
                        ZStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color("basic_text"))
                        }
                        .frame(width: 24, height: 20)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 12))
                }//Header HStack
                .background(scheme == .light ? .white : .black)
                //Category LIST
                VStack{
                    List{
                        //모든 자료, 분류되지 않은 자료
                        ForEach($categoryList.categories) { $category in
                            if category.order == 0 || category.order == 1 {
                                ZStack {
                                    HStack(spacing: 0){
                                        Spacer()
                                            .frame(width: screenWidth / 24)
                                        Text(category.name)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("basic_text"))
                                            .frame(width: screenWidth / 1.35, alignment: .leading)
                                        Text("\(category.numOfLink)")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("basic_text"))
                                            .frame(width: screenWidth / 11, alignment: .trailing)
                                        Spacer()
                                            .frame(width: screenWidth / 10)
                                    }
                                    Button(action: {
                                        withAnimation(.spring()){
                                            self.isShowingCategorySideMenuView = false //카테고리뷰 off
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            selectedCategoryId = category.categoryId
                                            selectedCategoryOrder = category.order
                                        }
                                    }) {
                                        Rectangle()
                                            .frame(width: screenWidth / 1.1)
                                            .opacity(0)
                                    }
                                }
                                .listRowBackground(selectedCategoryId == category.categoryId ? Color("selected_color") : .none)
                                .frame(width: screenWidth)
                            }
                        }
                        
                        //나머지 카테고리
                        ForEach($categoryList.categories) { $category in
                            if category.order != 0 && category.order != 1 {
                                CategoryRow(category: $category, detailCategory: $detailCategory, isPresentCategoryBottomSheet: $isPresentCategoryBottomSheet, isShowingCategorySideMenuView: $isShowingCategorySideMenuView,  selectedCategoryId: $selectedCategoryId, selectedCategoryOrder: $selectedCategoryOrder)
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
                    //바텀시트 -> isPresentCategoryBottomSheet
                    .bottomSheet(showSheet: $isPresentCategoryBottomSheet) {
                        CategorySheetView(category: $detailCategory, isPresentCategoryBottomSheet: $isPresentCategoryBottomSheet)
                            .environmentObject(scrapVM)
                            .environmentObject(userVM)
                    } onEnd: {
                        print("✅ category bottom sheet dismissed")
//                        self.isPresentCategoryBottomSheet = false //카테고리 바텀 시트 off
                    }
                }//CategoryList VStack
                .refreshable {
                    scrapVM.getCategoryListData(userID: userVM.userIndex)
                }
                .listStyle(PlainListStyle())
            }//VStack
            if isAddingCategory { //카테고리 추가 alert창 켜지면 뒷 배경 블러 처리
                Color("blur_background").ignoresSafeArea()
            }
//            if self.isPresentCategoryModalSheet {
//                Color("blur_background")
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        self.isPresentCategoryModalSheet = false
//                    }
//            }
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

//struct CategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryView(categoryList: .constant(CategoryResponse.Result(categories: [
//            CategoryResponse.Category(categoryId: 0, name: "전체 자료", numOfLink: 500, order: 0),
//            CategoryResponse.Category(categoryId: 1, name: "분류되지 않은 자료", numOfLink: 42, order: 1),
//            CategoryResponse.Category(categoryId: 2, name: "채용 공고 모음", numOfLink: 6, order: 2),
//            CategoryResponse.Category(categoryId: 3, name: "iOS 자료", numOfLink: 30, order: 3),
//            CategoryResponse.Category(categoryId: 4, name: "컴퓨터 사이언스 자료", numOfLink: 140, order: 4),
//            CategoryResponse.Category(categoryId: 5, name: "취준 팁 모음", numOfLink: 60, order: 5),
//            CategoryResponse.Category(categoryId: 6, name: "개발자 정보!", numOfLink: 20, order: 6),
//            CategoryResponse.Category(categoryId: 7, name: "iOS 자료", numOfLink: 60, order: 7),
//            CategoryResponse.Category(categoryId: 8, name: "iOS 자료", numOfLink: 60, order: 8),
//            CategoryResponse.Category(categoryId: 9, name: "iOS 자료", numOfLink: 60, order: 9),
//            CategoryResponse.Category(categoryId: 10, name: "iOS 자료", numOfLink: 60, order: 10)
//        ])), isShowingCategoryView: .constant(true), selectedCategoryId: .constant(0), detailCategory: <#Binding<CategoryResponse.Category>#>, selectedCategoryOrder: .constant(0))
//            .environmentObject(ScrapViewModel())
//    }
//}
