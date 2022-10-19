//
//  SideMenuView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import Combine

struct SideMenuView: View {
    @State private var arr = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    @Binding var categoryList : CategoryResponse.Result
    @State private var newCat = "" //초기화해줘야 함
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
                            proxy.scrollTo(arr.count, anchor: .top)
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
                        ForEach(arr, id:\.self) { i in
                            Text("row \(i)")
                                .font(.system(size: 16))
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.15), alignment: .leading)
                                .padding(.leading, 16)
                                .id(i)
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
//                        HStack{
//                            Text("category.name1")
//                                .font(.system(size: 16))
//                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.15), alignment: .leading)
//                            Text("10")
//                                .font(.system(size: 16))
//                                .frame(width: 30, alignment: .trailing)
//                        }
//                        .id(1)
//                        .listRowBackground(Color("light_blue"))
//                        HStack{
//                            Text("category.name2")
//                                .font(.system(size: 16))
//                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.15), alignment: .leading)
//                            Text("120")
//                                .font(.system(size: 16))
//                                .frame(width: 30, alignment: .trailing)
//                        }
//                        .id(2)
    //                    ForEach($categoryList.categories) { $category in
    //                        HStack{
    //                            Text(category.name)
    //                                .font(.system(size: 16))
    //                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.4), alignment: .leading)
    //                            Text("\(category.numOfLink)")
    //                                .font(.system(size: 16))
    //                                .frame(width: 30, alignment: .trailing)
    //                        }
    //                        .listRowBackground(self.selected == category.categoryId ? light_gray : Color(.white))
    //                        .onTapGesture { //클릭하면 현재 categoryID
    //                            self.selected = category.categoryId
    //                            vm.getData(userID: 2, catID: selected, seq: "desc")
    //                        }
    //                    }
                        if isAddingCategory { //카테고리 추가 버튼을 누른 경우 -> 보여짐
                            HStack{
                                TextField("새로운 카테고리", text: $newCat,
                                  onCommit: {
                                    vm.addNewCategory(newCat: newCat, userID: 2)
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
        .environment(\.editMode, .constant(.active))
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        arr.move(fromOffsets: source, toOffset: destination)
    }
    
    private func delete(offsets: IndexSet) {
        arr.remove(atOffsets: offsets)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 1)])), isShowingCateogry: .constant(true), selected: .constant(1))
            .environmentObject(ScrapViewModel())
    }
}
