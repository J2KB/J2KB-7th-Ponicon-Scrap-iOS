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
    //📌 test
    @State private var arr = [Item(id: 1, title: "Algorithm", num: 2), Item(id: 2, title: "DataStructure", num: 5), Item(id: 3, title: "Network", num: 4), Item(id: 4, title: "SQL", num: 6)]
    @State private var dragging: CategoryResponse.Category?
//    @State private var dragging: Item?
    @Binding var categoryList : CategoryResponse.Result
    @State private var newCat = ""
    @State private var isAddingCategory = false
    @Binding var isShowingCateogry : Bool
    @State private var maxCatName = 20
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //ScrapApp에서 연결받은 EnvironmentObject
    @Binding var selected : Int
    

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: -2){
                //HEADER
                HStack{
                    HStack(spacing: 12){
                        Button(action: {
                            withAnimation(.easeInOut){
                                isShowingCateogry = false
                            }
                        }){
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .frame(width: 10, height: 16)
                                .foregroundColor(.black)
                        }
                        Text("카테고리")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 70, height: 20, alignment: .leading)
                    }
                    Spacer()
                    Button(action: {
                        self.isAddingCategory.toggle() //카테고리 추가 토글
                        withAnimation {
//                            proxy.scrollTo(categoryList.categories.count) //scroll to last element(category)
//                            proxy.scrollTo(arr.count, anchor: .top)
                        }
                    }){
                        Image(systemName: isAddingCategory ? "xmark" : "plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 2))
                }
                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.72), height: 40)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                .background(.white)
                //Category LIST
                VStack{
                    List{
                        //📌 test
//                        ForEach(arr) { i in
//                            HStack{
//                                Text(i.title)
//                                    .font(.system(size: 16))
//                                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 1.8), alignment: .leading)
//                                    .padding(.leading, 12)
//                                Spacer()
//                                Text("\(i.num)")
//                                    .font(.system(size: 16))
//                                    .frame(width: 30, alignment: .trailing)
//                                Button(action: {
//
//                                }) {
//                                    Image(systemName: "pencil")
//                                        .resizable()
//                                        .frame(width: 18, height: 18)
//                                        .foregroundColor(.gray_bold)
//                                }
//                            }
//                            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.75))
//                            .onDrag {
//                                self.dragging = i
//                                return NSItemProvider(object: NSString())
//                            }
//                            .onDrop(of: [UTType.text], delegate: DragDelegate(current: $dragging))
//                        }
//                        .onDelete(perform: delete)
//                        .onMove(perform: {source, destination in //from source: IndexSet, to destination: Int
//                        })
                        //📌 real
                        ForEach($categoryList.categories) { $category in
                            HStack{
                                Text(category.name)
                                    .font(.system(size: 16))
                                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2), alignment: .leading)
                                Text("\(category.numOfLink)")
                                    .font(.system(size: 16))
                                    .frame(width: 30, alignment: .trailing)
                            }
                            .padding(.leading, 10)
                            .listRowBackground(self.selected == category.categoryId ? .gray_sub : Color(.white))
                            .onTapGesture { //클릭하면 현재 categoryID
                                self.selected = category.categoryId
                                vm.getData(userID: 16, catID: selected, seq: "seq")
                            }
                            .onDrag {
                                self.dragging = category
                                return NSItemProvider(object: NSString())
                            }
                            .onDrop(of: [UTType.text], delegate: DragDelegate(current: $dragging))
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: {source, destination in //from source: IndexSet, to destination: Int
                            //📡 카테고리 이동 통신
                            source.forEach { vm.moveCategory(from: $0, to: destination)} //카테고리 이동 배열 순서 변경
                        })
                        if isAddingCategory { //카테고리 추가 버튼을 누른 경우 -> 보여짐
                            HStack{
                                TextField("새로운 카테고리", text: $newCat,
                                  onCommit: {
                                    vm.addNewCategory(newCat: newCat, userID: 2) //📡 카테고리 추가 통신
                                    let newCategory = CategoryResponse.Category(categoryId: vm.categoryID, name: newCat, numOfLink: 0, order: 0)
                                    vm.appendCategory(newCategory: newCategory) //post로 추가된 카테고리 이름 서버에 전송
                                    newCat = ""
                                    isAddingCategory = false
                                  })
                                .padding(.leading, 16)
                                .disableAutocorrection(true) //자동 수정 비활성화
                                if !newCat.isEmpty {
                                    Image(systemName: "checkmark") //한 글자라도 있어야 버튼 활성화
                                        .foregroundColor(.gray_bold)
                                }
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 3.5))
                    .listStyle(PlainListStyle())
                }
            }
            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 3.5))
            .background(.white)
        }
    }
    
//    private func move(from source: IndexSet, to destination: Int) {
//        arr.move(fromOffsets: source, toOffset: destination)
//    }

    private func delete(indexSet: IndexSet) {
        for index in indexSet {
            vm.removeCategory(index: index)
        }
        //📡 카테고리 삭제 통신
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 1)])), isShowingCateogry: .constant(true), selected: .constant(1))
            .environmentObject(ScrapViewModel())
    }
}
